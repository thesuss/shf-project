# frozen_string_literal: true

#--------------------------
#
# @class Memberships::EnterGracePeriodMemberActions
#
# @desc Responsibility: Do all the things that need to be done when an entity enters the renewal grace period
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2022-05-21
#
#--------------------------------------------------------------------------------------------------
module Memberships
  class EnterGracePeriodMemberActions < MembershipActions

    LOGMSG_MEMBERSHIP_ENTERGRACEPERIOD = 'Membership entered grace period' unless defined? LOGMSG_MEMBERSHIP_ENTERGRACEPERIOD

    def self.other_keyword_args_valid?(_other_keyword_args)
      true
    end

    # Set membership to false
    # If we should send email send email to the user saying they are now in the renewal grace period
    # @return [True] if we are successful
    def self.accomplish_actions(entity, _send_email: SEND_EMAIL_DEFAULT, **_other_keyword_args)
      entity.update!(member: false)
      # MemberMailer.membership_entered_grace_period(entity, other_keyword_args).deliver if send_email

      true
    end

    def self.log_message_success
      LOGMSG_MEMBERSHIP_ENTERGRACEPERIOD
    end
  end

end
