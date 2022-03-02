class PaymentMailer < ApplicationMailer

  def payment_made(payment)
    return unless payment && (payment.membership_payment? || payment.branding_license_payment?)

    set_mail_info __method__, payment.user
    scope = 'mailers.payment_mailer.payment_made'    

    @ismembership = payment.membership_payment?
    @product = product(payment, scope)
    @product_with_name = product_with_name(payment, scope)
    @payment_date = payment_date(payment)
    @payment_amount = payment_amount(payment)
    @order_number = payment.klarna_id
    @membership_number = payment.user&.membership_number
    @company_number = payment.company&.company_number

    mail to: recipient_email, subject: t('subject', scope: scope, product: @product)
  end

  private

  def product(payment, scope)
    payment.membership_payment? ? t('membership', scope: scope) : t('h_brand', scope: scope)
  end

  def product_with_name(payment, scope)
    payment.membership_payment? ? t('membership', scope: scope) : t('h_brand_with_name', scope: scope, company: payment.company&.name)
  end

  def payment_date(payment)
    payment.updated_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S (%Z)')
  end

  def payment_amount(payment)
    payment.amount.nil? ? '' : payment.amount / 100   
  end

end