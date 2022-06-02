class PaymentsController < ApplicationController
  include Klarna::Errors
  include RobotsMetaTagShowActionOnly

  class NotAuthorizedError < Pundit::NotAuthorizedError
  end

  protect_from_forgery except: :webhook

  PAYMENT_EXCEPTIONS = [Klarna::Errors::KlarnaError, HTTParty::Error,
                        ActiveRecord::RecordInvalid, RuntimeError].freeze

  def create

    # The user wants to pay a fee (e.g. membership fee or branding fee)
    payment_type = params[:type]
    user_id      = params[:user_id]
    company_id   = params[:company_id] # if h-branding fee to be paid

    authorize Payment.new(user_id: user_id)

    if payment_type == Payment.membership_payment_type
      start_date, expire_date = User.next_membership_payment_dates(user_id)
      paid_item = I18n.t('payment.payment_type.member_fee')
      item_price = SHF_MEMBER_FEE
    else
      start_date, expire_date = Company.next_membership_payment_dates(company_id)
      paid_item = I18n.t('payment.payment_type.branding_fee')
      item_price = SHF_BRANDING_FEE
    end

    @payment = Payment.create!(payment_type: payment_type,
                               user_id: user_id,
                               company_id: company_id,
                               amount: item_price,
                               status: Payment.order_to_payment_status(nil),
                               payment_processor: Payment.payment_processor_klarna,
                               start_date: start_date,
                               expire_date: expire_date)

    payment_data = { id: @payment.id,
                     user_id: user_id,
                     type: payment_type,
                     currency: Payment.payment_currency,
                     item_price: item_price,
                     paid_item: paid_item,
                     urls:  klarna_order_urls(@payment.id, user_id,
                                              company_id, payment_type) }

    # Invoke Klarna API - returns an order to be used for checkout
    klarna_order = Klarna::Service.create_order(payment_data)

    # Save payment and render checkout form
    klarna_id = klarna_order['order_id']
    @payment.klarna_id = klarna_id
    @payment.status = Payment.order_to_payment_status(klarna_order['status'])
    @payment.save!

    log_klarna_activity('Create Order', 'info', @payment.id, klarna_id)

    @html_snippet = klarna_order['html_snippet']

  rescue *PAYMENT_EXCEPTIONS  => exception
    @payment.destroy if @payment&.persisted?

    log_klarna_activity('create order', 'error', nil, klarna_id, exception)

    helpers.flash_message(:alert, t('.something_wrong',
                                    admin_email: ENV['SHF_REPLY_TO_EMAIL']))

    notify_slack_of_exception(exception, __method__)

    redirect_back fallback_location: root_path
  end

  # https://developers.klarna.com/documentation/klarna-checkout/in-depth/confirm-purchase
  def confirmation

    payment_id = params[:id]
    klarna_id = params[:klarna_id]
    raise 'No Klarna order ID' unless klarna_id

    klarna_order = handle_order_confirmation(klarna_id, payment_id)

    current_user.reload

    account_page_link = helpers.link_to(t('menus.nav.users.your_account').downcase,
                                        user_path(params[:user_id]))

    helpers.flash_message(:notice, t('.success_html',
                                     account_page_link: account_page_link))

    log_klarna_activity('Order Confirmation', 'info', payment_id, klarna_id)

    @html_snippet = klarna_order['html_snippet']

  rescue *PAYMENT_EXCEPTIONS => exception
    log_klarna_activity('Order Confirmation', 'error', payment_id, klarna_id, exception)

    notify_slack_of_exception(exception, __method__)

    helpers.flash_message(:alert, t('payments.create.something_wrong',
                                    admin_email: ENV['SHF_REPLY_TO_EMAIL']))

    redirect_back fallback_location: root_path
  end


  # This is the klarna "push" action.  It is the "fallback" action in case
  # the "confirmation" action (see "confirmation" method here) does not occur.
  # https://developers.klarna.com/documentation/klarna-checkout/in-depth/confirm-purchase/

  # Fetch the order (Order Management API) and check if "captured_amount" is non-zero:
  #   If so, do nothing (order has been acknowledged and order amount captured).
  #   Otherwise, perform same actions as for "confirmation" action.
  def klarna_push
    klarna_id = params[:klarna_id]
    payment_id = params[:id]

    klarna_order = Klarna::Service.get_order(klarna_id)

    return if klarna_order['captured_amount'] != 0

    handle_order_confirmation(klarna_id, payment_id)

    log_klarna_activity('Webhook', 'info', payment_id, klarna_id)

  rescue *PAYMENT_EXCEPTIONS => exception
    log_klarna_activity('Webhook', 'error', payment_id, klarna_id, exception)
    notify_slack_of_exception(exception, __method__)
  ensure
    head :ok
  end

  private

  def handle_order_confirmation(klarna_id, payment_id)

    klarna_order = Klarna::Service.get_checkout_order(klarna_id)

    Klarna::Service.acknowledge_order(klarna_id)

    payment = Payment.find(payment_id)
    payment.update(status: Payment.order_to_payment_status(klarna_order['status']))
    payment.successfully_completed

    # Capture the order in Klarna (indicates the order has been filled and
    # payment settlement can occur)
    Klarna::Service.capture_order(klarna_id, klarna_order['order_amount'])

    klarna_order
  end

  def log_klarna_activity(activity, severity, payment_id, klarna_id, exception=nil)
    ActivityLogger.open(LogfileNamer.name_for('Klarna'), 'Payments', activity, false) do |log|
      log.record(severity, "Payment ID: #{payment_id}") if payment_id
      log.record(severity, "Klarna ID: #{klarna_id}") if klarna_id

      [exception, exception&.cause].each do |this_exception|
        next unless this_exception
        log.record(severity, "Exception class: #{this_exception.class}") if exception
        log.record(severity, "Exception message: #{this_exception.message}") if exception
      end
    end
  end

  def klarna_order_urls(payment_id, user_id, company_id, payment_type)
    urls = {}
    urls[:checkout] = payments_url(user_id: user_id, company_id: company_id,
                                   type: payment_type)

    # NOTE: '{checkout.order.id}' should appear *verbatim* in the URLs.
    urls[:confirmation] = payment_confirmation_url(id: payment_id,
                                                   user_id: user_id,
                                                   disable_language_change: true,
                                                   klarna_id: '{checkout.order.id}')

    urls[:push] = (SHF_WEBHOOK_HOST || root_url) +
                  payment_klarna_push_path(id: payment_id,
                                           klarna_id: '{checkout.order.id}').sub('/en', '')
    urls
  end

  def notify_slack_of_exception(exception, method_sym)
    class_and_method = "#{self.class.name}\##{method_sym}"

    [exception, exception.cause].each do |this_exception|
      break unless this_exception
      SHFNotifySlack.failure_notification(class_and_method, text: this_exception.message)
    end
  end
end
