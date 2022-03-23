#--------------------------
#
# @class Memberships::RestoreIndividualMemberActions
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
    class RestoreIndividualMemberActions < MembershipActions
  
      LOGMSG_RESTORE_MEMBERSHIP = 'Membership in grace period restored to current membership' unless defined? LOGMSG_RESTORE_MEMBERSHIP
  
  
      def self.other_keyword_args_valid?(_other_keyword_args)
        true
      end
  
      # Set membership to true
      # If we should send email:
      #   send email to the user saying that their membership is restored
      #
      def self.accomplish_actions(user, _send_email: SEND_EMAIL_DEFAULT, **_other_keyword_args)
        
        user.update!(member: true)
        # MemberMailer.membership_restored(user).deliver if send_email        
  
        true
      end
  
  
      def self.log_message_success
        LOGMSG_RESTORE_MEMBERSHIP
      end
    end
  
end
  