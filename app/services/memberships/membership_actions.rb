# frozen_string_literal: true


module Memberships

  class MembershipActionError < StandardError; end

  #--------------------------
  #
  # @class Memberships::MembershipActions
  #
  # @desc Responsibility: super class that defines the strategy for all Membership Actions
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   3/7/21
  #
  #--------------------------------------------------------------------------------------------------
  class MembershipActions

    SEND_EMAIL_DEFAULT = true unless defined? SEND_EMAIL_DEFAULT
    LOGMSG_INVALID_KEYWORD_ARGS = 'Invalid keyword args sent to Membership Action' unless defined? LOGMSG_INVALID_KEYWORD_ARGS

    # This is the main strategy (algorithm) for writing to the log(s) and doing the actions
    # needed.
    # Subclasses should define their own other_keyword_args_valid? and accomplish_actions methods.
    #
    # other_keyword_args is all keyword arguments passed after the first one (entity) and
    #   the (send_email: keyword argument) or the end
    def self.for_entity(entity, send_email: send_email_default, **other_keyword_args)

      if other_keyword_args_valid?(other_keyword_args)
        ActivityLogger.open(log_filename, self.name, log_message_success, false) do |log|
          successful = do_the_actions(entity, send_email: send_email, **other_keyword_args)
          if successful
            log.info("#{log_message_success}: #{entity.inspect}")
          else
            raise(MembershipActionError, "Failed: when trying to #{log_message_success} with #{entity.inspect}\n    args= send_email: #{send_email}  #{other_keyword_args.inspect}")
          end
        end
      else
        ActivityLogger.open(log_filename, self.class.to_s, log_message_success, false) do |log|
          log.warn("#{log_message_invalid_keyword_args}: entity: #{entity.inspect}, send_email: #{send_email}, #{other_keyword_args.inspect}")
        end
      end
    end

    # Subclasses should override this to validate the expected other keyword arguments
    # @return [true | false]
    def self.other_keyword_args_valid?(_other_keyword_args)
      raise NoMethodError, "#{__method__}: Subclasses must implement this method to validate the other keyword arguments given (return true or false)."
    end

    # Calls the accomplish_actions method to do what needs to be done.
    #
    # raise error if accomplish_actions failed
    # @return [True, False]
    def self.do_the_actions(entity, send_email:, **other_keyword_args)
      success = accomplish_actions(entity, send_email: send_email, **other_keyword_args)
      if success
        send_emails(entity, send_email: send_email, **other_keyword_args)
      else
        raise MembershipActionError
      end
      success
    end

    # Subclasses must define this.  Do all of the actions needed.
    # @return [True | False] - did this accomplish everything successfully?
    # @fixme renamed to actions_successful?
    def self.accomplish_actions(_entity, _send_email: send_email_default, **_other_keyword_args)
      raise NoMethodError, "#{__method__}: Subclasses must implement this method to do whatever is needed (for their action)."
    end

    # Subclasses may want to override (e.g. if they need to use multiple mailers to send emails, etc)
    def self.send_emails(entity, send_email: send_email_default, **other_keyword_args)
      mailer_class.send(mailer_method, entity, **other_keyword_args) if send_email
    end

    # This is a hook (opportunity) for subclasses and callers to do anything needed.
    # By default, do nothing (nothing else needs to be done)
    # @return [True, False]
    def self.do_specific_actions(_entity, _send_email, *)
      true
    end

    def self.send_email_default
      SEND_EMAIL_DEFAULT
    end

    # subclasses should override this if they need to send email
    def self.mailer_class
      NullMailer
    end

    # subclasses should override this if they need to send email
    def self.mailer_method
      :no_mail_sent
    end

    # Subclasses must override this to use the specific success message for their class.
    def self.log_message_success
      raise NoMethodError, "#{__method__}: Subclasses must implement this method with a meaningful success message for the log(s)."
    end

    # Note that the log filename is the MembershipStatusUpdater log!
    def self.log_filename
      LogfileNamer.name_for(MembershipStatusUpdater.name)
    end

    def self.log_message_invalid_keyword_args
      LOGMSG_INVALID_KEYWORD_ARGS
    end
  end

end
