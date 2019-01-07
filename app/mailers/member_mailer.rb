# Sends out emails to Members regarding changes in membership status, including:
# membership granted, renewed, soon-to-be-expired, etc.
class MemberMailer < ApplicationMailer


  def membership_granted(member)

    set_mail_info __method__, member
    @member = member
    mail to: recipient_email, subject: t('mailers.member_mailer.membership_granted.subject')

  end


  def membership_expiration_reminder(member)

    set_mail_info __method__, member
    @member      = member
    @expire_date = member.membership_expire_date
    mail to:      @recipient_email,
         subject: t('mailers.member_mailer.membership_will_expire.subject')

  end


  def h_branding_fee_past_due(company, recipient)

      set_mail_info __method__, recipient
      @member  = recipient
      @company = company
      mail to: @recipient_email,  subject: t('mailers.member_mailer.h_branding_fee_past_due.subject')
  end

end
