# frozen_string_literal: true

#--------------------------
#
# @class Memberships::EnterGracePeriodCompanyMemberActions
#
# @desc Responsibility: Do the specific things that need to be done when a Company enters the renewal grace period.
#   Currently we do not send email, so we don't need to override the parent class :mailer_class or :mailer_method.
#   This class is here because it will be specifically called by the IsMember::enter_grace_period method
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   4/1/21
#
#--------------------------------------------------------------------------------------------------
module Memberships
  class EnterGracePeriodCompanyMemberActions < EnterGracePeriodMemberActions
  end
end
