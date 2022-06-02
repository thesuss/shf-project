# Log messages:
#
LOGMSG_APP_UPDATED = 'SHF_application updated' unless defined? LOGMSG_APP_UPDATED
LOGMSG_PAYMENT_MADE = 'Payment made' unless defined? LOGMSG_PAYMENT_MADE
LOGMSG_CHECKLIST_COMPLETED = 'Checklist completed' unless defined? LOGMSG_CHECKLIST_COMPLETED

LOGMSG_USER_UPDATED = 'User updated' unless defined? LOGMSG_USER_UPDATED

#--------------------------
#
# @class MembershipStatusUpdater
#
# @desc Responsibility:  Keep membership status up-to-date based the current business rules
#    and requirements.
#  - gets notifications from events in the system and does what is needed with them to
#    update the status of memberships for people in the system
#
#    This is a Singleton.  Only 1 is needed for the system.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/21/17
# @file membership_status_updater.rb
#
#
# Only check to see if requirements have been satisfied for Renewal or Membership when:
#   * a payment is made, or
#   * a checklist is completed (e.g. 'Agree to all Ethical Guidelines' checklist)
#
# Otherwise each time the requirements for renewal or membership are checked (e.g. at login),
# the payment and non-payment requirements will be satisfied and membership or renewal will be
# incorrectly granted again.
# In other words, the only time that we _should_ check to see if membership or renewal can be granted
# is when a payment is made or a checklist is completed (e.g. 'Agree to all Ethical Guidelines' checklist)
#
#
# The Observer pattern is used to send notifications (methods) when something
# 'interesting' has changed.  When the MembershipStatusUpdater receives one of these
# notifications, it checks the membership to see if it needs to be changed (updated
# or revoked).  It does this via the :check_requirements_and_act({ entity: user })
# method.  (This method is the public interface and main method for all
# Updater classes.)
#
# This check is logged with the ActivityLogger so that anything that happens is
# logged.
#
#
#   MembershipStatusUpdater has the responsibility of checking to see if the membership status
#   should be changed (updated) based on the current business rules.
#   Thus all of the business rules can be in just _one place_ (DRY).
#   Only 1 class has the responsibility for enforcing them.  No other classes have to care about them.
#
#   Satisfies the "Open/Closed" principle in SOLID:  putting the business logic
#   into 1 Observer class keeps it open to extension changes (just this class)
#   but closed to having to modify lots of code when the requirements change
#
# @fixme what about sending email when updating membership status for a Company?
#--------------------------

class MembershipStatusUpdater
  include Singleton

  SEND_EMAIL_DEFAULT = true

  # -----------------------------------------------------------------------------------
  # Notifications received from Notifying classes:
  # - - -
  # Could set up some more generalized meta-code to get information from notifications sent,
  # but this is simple to maintain because it is explicit.
  #

  def shf_application_updated(shf_app, send_email: send_email_default)
    update_membership_status(shf_app.user, shf_app, logmsg_app_updated, send_email: send_email)
  end

  # Check to see if the user can now be granted membership or renewed.
  # @fixme don't always check_grant... for the payment.user It might be a Company
  def payment_made(payment, send_email: send_email_default)
    check_grant_membership_or_renew(payment.user, payment, logmsg_payment_made, send_email: send_email) if payment.membership_payment?
  end

  # Check to see if the user can now be granted membership or renewed.
  def checklist_completed(checklist_root, send_email: send_email_default)
    check_grant_membership_or_renew(checklist_root.user, checklist_root, logmsg_checklist_completed, send_email: send_email)
  end

  def user_updated(user, send_email: send_email_default)
    update_membership_status(user, user, logmsg_user_updated, send_email: send_email)
  end

  # end of Notifications received from observed classes
  # -----------------------------------------------------------------------------------

  def check_grant_renew_and_status(entity, notifier = nil, reason_update_happened = nil,
                                   send_email: send_email_default)

    check_grant_membership_or_renew(entity, notifier, reason_update_happened,
                                    send_email: send_email)

    update_membership_status(entity, notifier, reason_update_happened,
                             send_email: send_email)
  end

  # A payment is made by the payor, for the membership_entity
  def check_grant_membership_or_renew(membership_entity, notifier = nil, reason_update_happened = nil,
                                      send_email: send_email_default)
    today = Date.current

    log_and_check("#{__method__}", membership_entity, [notifier], notifier, reason_update_happened) do |entity, _other_args, log|
      # next_membership_start_date =  user.membership_expire_date.nil? ? today : user.membership_expire_date + 1.day
      next_membership_start_date = if entity.membership_expire_date.nil? || entity.membership_expire_date < today
                                     today
                                   else
                                     entity.membership_expire_date + 1
                                   end

      if entity.not_a_member? || entity.former_member?
        if entity.requirements_for_membership.satisfied?(entity: entity)
          entity.start_membership!(date: next_membership_start_date, send_email: send_email)
          log.info(entity.membership_changed_info)
        end

      elsif entity.current_member? || entity.in_grace_period?
        if entity.requirements_for_renewal.satisfied?(entity: entity)
          entity.renew!(date: next_membership_start_date, send_email: send_email)
          log.info(entity.membership_changed_info)
        end
      end
    end
  end

  #  This is the main method for checking and changing the membership status.
  #     TODO: for a given date
  #
  def update_membership_status(given_user, notifier = nil, reason_update_happened = nil,
                               send_email: send_email_default)
    today = Date.current

    log_and_check("#{__method__}", given_user, [notifier], notifier, reason_update_happened) do |entity, _other_args, log|

      if entity.current_member?
        if entity.membership_expired_in_grace_period?(today)
          entity.start_grace_period!(send_email: send_email)
          log.info(entity.membership_changed_info)

        elsif entity.membership_past_grace_period_end?(today)
          # This should only happen when seeding. But just in case the membership status has not been updated for
          # a while and so hasn't transitioned to in_grace_period, we'll do it manually now and then
          # go on and transition to a former member
          entity.start_grace_period!(send_email: send_email)
          log.info(entity.membership_changed_info)
          entity.make_former_member!(send_email: send_email)
          log.info(entity.membership_changed_info)
        end

      elsif entity.in_grace_period?
        if entity.membership_past_grace_period_end?(today)
          entity.make_former_member!(send_email: send_email)
          log.info(entity.membership_changed_info)
        end
        if entity.membership_current?
          entity.restore_membership!(send_email: send_email)
          log.info(entity.membership_changed_info)
        end
      end
    end
  end

  def log_and_check(calling_method, membership_entity, other_args, notifier, reason_update_happened)
    ActivityLogger.open(log_filename, self.class.to_s, calling_method, false) do |log|
      log.info("#{calling_method} for #{membership_entity.inspect}")
      log.info("#{reason_update_happened}: #{notifier.inspect}") unless notifier.blank?
      yield(membership_entity, other_args, log) if block_given?
    end
  end

  def send_email_default
    SEND_EMAIL_DEFAULT
  end

  def logmsg_app_updated
    LOGMSG_APP_UPDATED
  end

  def logmsg_user_updated
    LOGMSG_USER_UPDATED
  end

  def logmsg_payment_made
    LOGMSG_PAYMENT_MADE
  end

  def logmsg_checklist_completed
    LOGMSG_CHECKLIST_COMPLETED
  end

  # -----------------------------------------------------------------------------------------------

  private

  def log_filename
    LogfileNamer.name_for(self.class.name)
  end
end
