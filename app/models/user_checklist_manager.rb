#--------------------------
#
# @class UserChecklistManager
#
# @desc Responsibility: Handle all behavior and queries for a UserChecklist associated with a User
#
# Current members:  They do not need to agree to the Membership Guidelines checklist until they renew.
# Anyone that is not a member on the 'start requiring membership guidelines date'
# must complete the checklist as a membership requirement.
# Anyone that is already a member on the "start requiring membership guidelines date"
#  does NOT need to complete the checklist -- until they renew.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   1/23/20
#
#--------------------------


class UserChecklistManager


  MEMBERSHIP_GUIDELINES_CHECKLIST_REQD_START = Time.zone.parse(ENV['SHF_MEMBERSHIP_GUIDELINES_CHECKLIST_REQUIRED_START_DATE'])


  def self.completed_membership_guidelines_checklist?(user)
    membership_guidelines_list_for(user)&.all_completed?
  end


  # @return [ nil | UserChecklist] - return nil if there aren't any, else return the most recent one
  def self.membership_guidelines_list_for(user)
    UserChecklist.membership_guidelines_for_user(user)&.last
  end


  # Is this user required to complete a Membership Guideline checklist?
  # As of 2020-01-23,
  # If someone is a current member as of < when the requirement starts >,
  #   then they do _not_ have to complete the membership guidelines checklist until they renew.
  #   else they DO have to complete the membership guidelines checklist.
  #
  # We only have payment dates and membership expiration dates to work with.
  #
  # Note that it is possible someone has paid ahead so that their membership term doesn't expire until
  #   AFTER   1 membership term (= 1 year) after the requirement starts
  #
  #
  def self.must_complete_membership_guidelines_checklist?(user)
    raise ArgumentError, "User should not be nil. #{__method__}" if user.nil?

    right_now = Time.zone.now
    return false if right_now < MEMBERSHIP_GUIDELINES_CHECKLIST_REQD_START
    return true unless user.membership_current?

    # They are are current member and today is after the day we start requiring the Membership Guidelines checklist

    one_term_after_req_start_date = User.expire_date_for_start_date(membership_guidelines_reqd_start_date)

    if user.membership_expire_date < one_term_after_req_start_date
      false # today is before the membership expire date else they would no longer be a member.
    else
      # false if last payment made was _before_ the requirements start date
      if user.most_recent_payment.created_at < membership_guidelines_reqd_start_date
        false
      else
        true
      end
    end

  end


  def self.membership_guidelines_reqd_start_date
    MEMBERSHIP_GUIDELINES_CHECKLIST_REQD_START
  end

end
