# Preview all emails at http://localhost:3000/rails/mailers

class PaymentMailerPreview < ActionMailer::Preview

  def membership_fee_payment_made
    payment = Payment.completed.member_fee.last
    PaymentMailer.payment_made(payment)
  end

  def branding_fee_payment_made
    payment = Payment.completed.branding_fee.last
    PaymentMailer.payment_made(payment)
  end

end
