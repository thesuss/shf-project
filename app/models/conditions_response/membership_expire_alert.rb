class MembershipExpireAlert

  def self.condition_response(condition, log)

    return unless condition.name == 'membership_will_expire'

    send_membership_expiration_reminder(condition.config, log)
  end

  def self.send_membership_expiration_reminder(config, log)

    User.all.each do |user|
      if user.membership_current?
        days_until = (user.membership_expire_date - Date.current).to_i

        if config[:days].include?(days_until)

          begin
            mail_response = MemberMailer.membership_expiration_reminder(user).deliver_now
            log_mail_response(log, mail_response, user.email)

          rescue => mailing_error
            log_failure(log, user.email, mailing_error)
          end

        end
      end
    end
  end


  private

  def self.log_mail_response(log, mail_response, user_email)
    mail_response.errors.empty? ? log_success(log, user_email) : log_failure(log, user_email)
  end


  def self.log_success(log, user_email)
    log.record('info', "Expire alert sent to #{user_email}.")
  end


  def self.log_failure(log, user_email, error = '')
    log.record('info', "Expire alert mail ATTEMPT FAILED: to #{user_email}. #{error} Also see for possible info #{ApplicationMailer::LOG_FILE} ")
  end
end
