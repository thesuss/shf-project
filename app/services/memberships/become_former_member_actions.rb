# frozen_string_literal: true

#--------------------------
#
# @class Memberships::BecomeFormerMemberActions
#
# @desc Responsibility: Do all the things that need to be done when a membership enters the renewal grace period.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2022-05-21
#
#--------------------------------------------------------------------------------------------------
module Memberships
  class BecomeFormerMemberActions < MembershipActions

    LOGMSG_MEMBERSHIP_FORMER = 'Membership now a former membership' unless defined? LOGMSG_MEMBERSHIP_FORMER

    def self.other_keyword_args_valid?(_other_keyword_args)
      true
    end

    # Set membership to false
    # If we should send email:
    #   send email to the user saying they are now a former member and have to re-apply
    # @return [True, False]
    def self.accomplish_actions(entity, _send_email: SEND_EMAIL_DEFAULT, **_other_keyword_args)
      entity.update!(member: false)
      true
    end

    def self.log_message_success
      LOGMSG_MEMBERSHIP_FORMER
    end
  end

end
