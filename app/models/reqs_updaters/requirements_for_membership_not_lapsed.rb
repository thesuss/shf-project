#--------------------------
#
# @class RequirementsForMembershipNotLapsed
#
# @desc Responsibility: Knows what the requirements are for determining
#                       if a membership has not lapsed.
#                       Is always the opposite of RequirementsForMembershipLapsed
#
#
#       This is a very simple class because the requirements are currently very simple.
#       The importance is that
#       IT IS THE ONLY PLACE THAT CODE NEEDS TO BE TOUCHED IF MEMBERSHIP REQUIREMENTS ARE CHANGED.
#
#  Only 1 is needed for the system.
#  This is implemented as a Class instead of a Singleton, but either approach is valid.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/23/17
# @file requirements_membership_not_lapsed.rb
#
#--------------------------


class RequirementsForMembershipNotLapsed < AbstractRequirements

  def self.has_expected_arguments?(args)
    RequirementsForMembershipLapsed.has_expected_arguments?(args)
  end


  def self.requirements_met?(args)
    ! RequirementsForMembershipLapsed.requirements_met?(args)
  end

end
