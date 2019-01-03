# Abstract parent class for all alerts that send out emails to users in Companies
#
# Responsibility: sets the information needed so that the parent class(es) can
#  process the condition for an email sent to users in Companies
#
#
#  SUBCLASSES MUST REDEFINE THESE METHODS:
#     send_alert_this_day?
#     mailer_method
#
class CompanyEmailAlert < EmailAlert



  # Send the email to the entity. Put an entry in the log file about it.
  #
  # Send an email to each recipient.
  # Log the response (success or failure) to the log
  #
  # @param company [Company] - the company whose recipients will receive the email alert
  # @param log [ActivityLog] - the log to record the response
  #
  def send_email(company, log)

    company_recipients(company).each do |member|
      begin
        mail_response = mail_message(company, member).deliver_now
        log_mail_response(log, mail_response, [company, member])

      rescue => mailing_error
        # must pass in an Array of the email; when successful this is a Mail::AddressContainer
        log_failure(log, log_msg_start,
                    log_str_maker.failure_info([company, member]),
                    mailing_error)
      end
    end

  end


  def entities_to_check
    Company.all
  end


  def mailer_class
    MemberMailer
  end


  # create the mail message by sending :mailer_method to the :mailer_class
  def mail_message(company, member)
    mailer_class.send(mailer_method, company, member)
  end


  # This method returns the list of recipients for the emails.
  # Subclasses can redefine this as needed.
  def company_recipients(company)
    company.current_members
  end


  def success_str(company, member)
    info_str(company, member)
  end


  def failure_str(company, member)
    info_str(company, member)
  end


  # Return a log string maker specific to this class and subclasses
  #
  def log_str_maker
    @log_str_maker ||= AlertLogStrMaker.new(self, :success_str, :failure_str)
  end


  # --------------------------------------------------------------------

  private


  def info_str(company, member)
    "to #{user_info(member)} #{company_info(company)}"
  end


  def user_info(user)
    user.nil? ? 'user is nil' : "user id: #{user.id} email: #{user.email}"
  end


  def company_info(company)
    company.nil? ? 'company is nil' : "company id: #{company.id} name: #{company.name}"
  end

end
