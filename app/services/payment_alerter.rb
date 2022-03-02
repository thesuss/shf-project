class PaymentAlerter
  include Singleton

  def payment_made(payment)
    PaymentMailer.payment_made(payment).deliver
  end
        
end
    