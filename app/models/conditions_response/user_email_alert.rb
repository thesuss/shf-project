# Abstract parent class for all alerts that send out emails to users
#
#  * knows if an alert needs to be sent today (or on _this_date_)
#  * knows the name of the method to send to MemberMailer to send out the
#     alert to a user
#
#  TODO If each class is responsible for doing 1 thing -- i.e. sending out 1
#   kind of alert for 1 condition, then is 'condition' really needed?
#     (If/when we have situations when 1 class needs to handle more than 1
#      condition _and_ we must have it handled only within 1 class,
#        then we can create the condition attribute.)
#
class UserEmailAlert


  # TODO this class is an instantiation of the Condition; why pass it again as an arg?
  def self.condition_response(_condition, config, log, this_date: DateTime.now.utc)

    User.all.each do |user|

      if send_alert_this_day?(config, user, this_date)
        MemberMailer.send(mailer_method, user)
        log.record('info', log_message(log_msg_start, user.email))
      end

    end

  end


  # method to improve readability. returns true if day_number is in config[:days]
  #
  # Expects config to include the :days key; returns false if it is not there
  #
  # If config is not a Hash, raises an Error because it really _should_ be a Hash
  #  (it's a programming error to call this otherwise!)
  #
  def self.send_on_day_number?(day_number, config)
    config.fetch(:days, false) ? config[:days].include?(day_number) : false
  end


  # Subclasses should define this by checking information for the user
  # computing whatever date information is necessary to determine if
  # an alert should be sent out today.
  # Ex:
  #   def self.send_alert_this_day?(config, user)
  #     days_until = (user.membership_expire_date - Date.current).to_i
  #     user.membership_current? &&  config[:days].include?(days_until)
  #   end
  #
  #
  # @param config [Object] - configuration information used to determine if an alert should be sent
  # @param user [User] - the user we are checking and, if appropriate, will send the alert to
  # @param this_date [DateTime] - (defaults to today) the date that we are using
  #                      to check the condition.  in UTC
  #
  def self.send_alert_this_day?(_config, _user, _this_date = DateTime.now.utc)
    raise NoMethodError, "Subclass must define the #{__method__} method and return true or false", caller
  end


  # This is the method sent to the MemberMailer when this condition
  # needs to send out an email.
  #
  # Subclasses must redefine this and return a symbol
  # Ex:
  #   def self.mailer_method
  #     :membership_expiration_reminder
  #   end
  def self.mailer_method
    raise NoMethodError, "Subclass must define the #{__method__} method and return a Symbol", caller
  end


  # This string is the start of the line logged to the Alert log when
  # this condition sends out an email = the name of the class
  def self.log_msg_start
    self.name
  end


  def self.log_message(message_start = '', user_email = '')
    "#{message_start} alert sent to #{user_email}"
  end


  SECONDS_IN_A_DAY = 86400 # 60 * 60 * 24

  # (Utility method for working with dateTimes (helps readability))
  #
  # The whole number of days since time1 up to time2 (time2 - time1),
  # rounding UP to the next whole number of days.
  # Ex:
  #     days_since( Thu, 01 Nov 2018 00:00:00 UTC +00:00,
  #                 Thu, 02 Nov 2018 00:00:01 UTC +00:00 )
  #    will return 2 days because that's 1 day and 1 minute.
  #
  # This is because this method is using to determine things like "is a payment late?"
  # and if the payment is 1 minute past due, then it is late.  So it makes sense
  # to round up to the next whole day.
  #
  #
  # @param time1 [Time] - the starting point: days since this time
  # @param time2 [Time] (optional; defaults to Time.utc)
  #                              - the date we want to move forward (or backwards) to
  #
  # @return the number of days between 2 Times (time2 - time1)
  def self.days_since(time1, time2 = Time.zone.now)
    daystart2 = time2.beginning_of_day
    daystart1 = time1.beginning_of_day

    (daystart2 - daystart1).to_i / SECONDS_IN_A_DAY
  end

end
