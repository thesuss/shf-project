# frozen_string_literal: true

#--------------------------
#
# @class Memberships::NewUserMembershipActions
#
# @desc Responsibility: Do the specific things that need to be done when a new User membership is granted.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   3/7/21
#
#--------------------------------------------------------------------------------------------------
module Memberships
  class NewUserMembershipActions < NewMembershipActions

    def self.mailer_class
      ::MemberMailer
    end

    def self.mailer_method
      :membership_granted
    end
  end
end
