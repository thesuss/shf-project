# frozen_string_literal: true

#--------------------------
#
# @class Memberships::RenewMembershipActions
#
# @desc Responsibility: Do all the things that need to be done when a membership is renewed.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2022-05=21
#
# TODO: what if they are a current_member and the last day > the date?
#   end the current membership on (date - 1 day) and start the new one on the date?
#--------------------------------------------------------------------------------------------------
module Memberships
  class RenewMembershipActions < NewRenewMembershipActions

    LOGMSG_MEMBERSHIP_RENEWED = 'Membership renewed' unless defined? LOGMSG_MEMBERSHIP_RENEWED

    def self.mailer_class
      MemberMailer
    end

    def self.mailer_method
      :membership_renewed
    end

    def self.log_message_success
      LOGMSG_MEMBERSHIP_RENEWED
    end
  end
end
