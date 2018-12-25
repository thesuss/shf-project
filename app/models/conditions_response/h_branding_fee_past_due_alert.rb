# This emails all current members in a company if the h-branding fee is past due.
#
# The first day the H-branding fee is due (a.k.a "day zero") is
# the date of the _earliest_ membership fee payment of the current members in the company.
#
class HBrandingFeePastDueAlert < CompanyEmailAlert


  # Send the alert if the company has not paid the H-Branding license ( = :branding_licensed)
  # and the company has current members.
  #
  def send_alert_this_day?(timing, config, company)

    return false if company.branding_license?

    current_members = company.current_members
    return false if current_members.empty?

    earliest_member_fee_paid = current_members.map(&:membership_start_date).sort.first

    day_to_check = self.class.days_today_is_away_from(earliest_member_fee_paid, timing)

    send_on_day_number?(day_to_check, config)

  end


  def mailer_method
    :h_branding_fee_past_due
  end


  def mailer_args(company)
    [company, company.current_members]
  end

end
