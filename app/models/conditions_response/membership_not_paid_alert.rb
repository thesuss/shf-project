# Send out an email if the membership fee has not been paid
# and the days past due is in the configuration list of days (config[:day])
class MembershipNotPaidAlert < UserEmailAlert


  def self.send_alert_this_day?(config, user, this_date)

    return false unless user.has_approved_shf_application?

    membership_payment_due = User.next_membership_payment_date(user.id)
    days_past_due          = days_since(membership_payment_due, this_date)

     send_on_day_number?(days_past_due, config)
  end


  def self.mailer_method
    :membership_payment_due
  end

end
