class PaymentMailer < ApplicationMailer

  include PaymentsHelper

  def payment_made(payment)
    return unless payment && (payment.membership_payment? || payment.branding_license_payment?)

    set_mail_info __method__, payment.user
    scope = 'mailers.payment_mailer.payment_made'

    @ismembership = payment.membership_payment?
    @product = product(payment, scope)
    @product_with_name = product_with_name(payment, scope)
    @payment_date = payment_date(payment)
    @payment_amount = payment_amount(payment)
    @order_number = payment.processor_id
    @membership_number = payment.user&.membership_number
    @company_number = payment.company&.company_number
    @processor = payment.payment_processor

    mail to: recipient_email, subject: t('subject', scope: scope, product: @product)
  end

end
