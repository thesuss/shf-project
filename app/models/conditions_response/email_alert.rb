# Abstract parent class for all alerts that send out emails
#
# Responsibility: loops through a list of entities, checking each one
#       to see if an email needs to be sent
#
#  * knows how to loop through all <items> and check to see if an alert
#     needs to be sent
#  * knows how to send the email (using the mailer, mailer_method, and
#     mailer_args)
#  * knows how to create a string to log a successful email sent
#  * knows how to create a string to log a failed email attempt
#
# This is a Singleton because subclasses may need their own instance of an
#  AlertLogStringMaker. (Cannot accomplish that with a class variable).
#
#  SUBCLASSES MUST REDEFINE THESE METHODS:
#     entities_to_check
#     mailer_class
#     mailer_args
#     success_str
#     failure_str
#
#     send_alert_this_day?
#     mailer_method
#
#
#  All dates used are a Date (not a Time or DateTime). This allows us to easily
#  determine the number of days between two dates.
#
class EmailAlert < ConditionResponder


  include Singleton

  # pass the class method call to the singleton instance
  def self.condition_response(condition, log)
    self.instance.condition_response(condition, log)
  end


  # Loop through all 'entities' and send them an email if an alert should be sent today
  def condition_response(condition, log)

    config = self.class.get_config(condition)
    timing = self.class.get_timing(condition)

    entities_to_check.each do | entity |
      send_email(entity, log) if send_alert_this_day?(timing, config, entity)
    end

  end


  # Send the email to the entity. Put an entry in the log file about it.
  def send_email(entity, log)
    begin
      mail_response = mail_message(entity).deliver_now
      log_mail_response(log, mail_response, entity)

    rescue => mailing_error
      log_failure(log, log_msg_start,
                  log_str_maker.failure_info([entity]),
                  mailing_error)
    end
  end


  # create the mail message by sending :mailer_method to the :mailer_class
  def mail_message(entity)
    mailer_class.send(mailer_method, *(mailer_args(entity)) )
  end



  # The list of entities that will be checked to see if an email needs to be sent
  #
  # SUBCLASSES SHOULD REDEFINE THIS TO SOMETHING USEFUL
  #  Ex:  Users.all
  #
  # @return [Array] - the list of entities that will be looped thru
  def entities_to_check
    raise NoMethodError, "Subclass must define the #{__method__} method and return a list of entities to check", caller
  end


  # The Mailer class to send :mailer_method to. It should be able to create and deliver
  # the email.
  #
  # Ex:  MemberMailer
  #
  def mailer_class
    raise NoMethodError, "Subclass must define the #{__method__} method and return the Mailer class to use", caller
  end



  # The arguments passed to the mailer method.
  #
  # SUBCLASSES MUST REDEFINE THIS TO SOMETHING USEFUL
  #  Ex:  [user, user_company ]
  #
  # @return [Array] - arguments to pass to the mailer method
  def mailer_args(_entity)
    raise NoMethodError, "Subclass must define the #{__method__} method and return an Array of arguments", caller
  end


  # method to improve readability. returns true if day_number is in config[:days]
  #
  # Expects config to include the :days key; returns false if it is not there
  #
  # If config is not a Hash, raises an Error because it really _should_ be a Hash
  #  (it's a programming error to call this otherwise!)
  #
  # @param day_number [Integer] - the number of days away from today (before, after, or on)
  # @param config [Hash] - other configuration info
  def send_on_day_number?(day_number, config)
    config.fetch(:days, false) ? config[:days].include?(day_number) : false
  end


  # Subclasses should define this by checking information for the user
  # computing whatever date information is necessary to determine if
  # an alert should be sent out today.
  # Ex:
  #   def send_alert_this_day?(timing, config, user)
  #     days_until = (user.membership_expire_date - Date.current).to_i
  #     user.membership_current? &&  config[:days].include?(days_until)
  #   end
  #
  # Does every implementation take the form:
  #
  #    return_false_condition (ex: return false unless user.membership_current?)
  #
  #    day_to_check = <determined somehow>
  #
  #    if timing_is_repeat_every?(timing)
  #       is_today_a_repeat_day?(config[:starting_date], config[:days])
  #     else
  #       day_to_check = Date.current - config[:starting_date]
  #       send_on_day_number?(day_to_check, config)
  #     end
  #
  # If so, we can abstract that to here and have subclasses just provide the
  # method for return_false_condition and for determining the day_to_check
  #
  # @param timing [Timing] - the relative timing of the alerts
  # @param config [Object] - configuration information used to determine if an alert should be sent
  # @param entity [Object] - the entity (e.g. user or company) we are checking and,
  #                          if appropriate, will send the alert to
  #
  def send_alert_this_day?(_timing, _config, _entity)
    raise NoMethodError, "Subclass must define the #{__method__} method and return true or false", caller
  end


  # This is the method sent to the MemberMailer when this condition
  # needs to send out an email.
  #
  # Subclasses must redefine this and return a symbol
  # Ex:
  #   def mailer_method
  #     :membership_expiration_reminder
  #   end
  def mailer_method
    raise NoMethodError, "Subclass must define the #{__method__} method and return a Symbol", caller
  end


  # Return a log string maker
  #
  def log_str_maker
    @log_str_maker ||= AlertLogStrMaker.new(self, :success_str, :failure_str)
  end


  # @param log [ActivityLog] - the log the message will be written to
  # @param mail_response [Mail::Message] - checked to see if it was successful or not
  # @param entity [Object] - the entity that was sent the email (a User; a Company; etc)
  #
  def log_mail_response(log, mail_response, entity )
    mail_response.errors.empty? ? log_success(log, log_msg_start, log_str_maker.success_info(entity))
        : log_failure(log, log_msg_start, log_str_maker.failure_info(entity))
  end


  def log_success(log, msg_start, info_str)
    log.record('info', "#{msg_start} email sent #{info_str}.")
  end


  def log_failure(log, msg_start, info_str, error = '')
    log.record('error', "#{msg_start} email ATTEMPT FAILED #{info_str}. #{error} Also see for possible info #{ApplicationMailer::LOG_FILE} ")
  end


  # This string is the start of the line logged to the Alert log when
  # this condition sends out an email = the name of the class
  def log_msg_start
    self.class.name
  end


  # Given the information, return a string to write to the log upon success
  #
  # SUBCLASSES SHOULD REDEFINE THIS TO SOMETHING USEFUL
  #
  def success_str(_args)
    raise NoMethodError, "Subclass must define the #{__method__} method and return a string", caller
  end


  # Given the information, return a string to write to the log upon failure
  #
  # SUBCLASSES SHOULD REDEFINE THIS TO SOMETHING USEFUL
  #
  def failure_str(_args)
    raise NoMethodError, "Subclass must define the #{__method__} method and return a string", caller
  end

end
