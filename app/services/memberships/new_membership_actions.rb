# frozen_string_literal: true

#--------------------------
#
# @class Memberships::NewMembershipActions
#
# @desc Responsibility: Do all the things that need to be done when a new membership is started
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2022-05-21
#
# TODO: what if they are a current_member and the last day > the date?
#   end the current membership on (date - 1 day) and start the new one on the date?
#
#--------------------------------------------------------------------------------------------------
module Memberships
  class NewMembershipActions < NewRenewMembershipActions

    LOGMSG_MEMBERSHIP_GRANTED = 'New membership granted' unless defined? LOGMSG_MEMBERSHIP_GRANTED

    # Create a new membership with the first day as the given first_day
    # Set the membership number for the entity
    # If we should send email:
    #   send email to the entity saying their membership is granted, and
    #   send email to the admin if this is the first membership AND the entity has a company in good standing
    # @return [True, False]
    def self.accomplish_actions(entity, send_email: SEND_EMAIL_DEFAULT, **other_keyword_args)
      if super
        assign_membership_number(entity)
        if send_email
          AdminAlerter.instance.new_membership_granted(entity, deliver_email: send_email) # @fixme always send this? or just for Users?
        end
        true
      else
        false
      end
    end

    def self.log_message_success
      LOGMSG_MEMBERSHIP_GRANTED
    end

    def self.assign_membership_number(entity)
      membership_num = entity.issue_membership_number
      entity.update!(membership_number: membership_num)
    end
  end
end
