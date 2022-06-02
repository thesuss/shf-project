# frozen_string_literal: true

#--------------------------
#
# @class Memberships::RestoreMemberActions
#
# @desc Responsibility: Do all the things that need to be done when a membership
#   in the grace period is restored to a current membership.
#
#
# @author Robert Cram
# @date   14/1/21
#
#--------------------------------------------------------------------------------------------------
module Memberships
  class RestoreMemberActions < MembershipActions

    LOGMSG_RESTORE_MEMBERSHIP = 'Membership in grace period restored to current membership' unless defined? LOGMSG_RESTORE_MEMBERSHIP

    def self.other_keyword_args_valid?(_other_keyword_args)
      true
    end

    # Set membership to true
    # If we should send email:
    #   send email to the entity saying that their membership is restored
    # @return [True, False]
    def self.accomplish_actions(entity, _send_email: SEND_EMAIL_DEFAULT, **_other_keyword_args)
      entity.update!(member: true)
      # mailer_class.send(mailer_method, entity, other_keyword_args) if send_email

      true
    end

    def self.log_message_success
      LOGMSG_RESTORE_MEMBERSHIP
    end
  end
end
