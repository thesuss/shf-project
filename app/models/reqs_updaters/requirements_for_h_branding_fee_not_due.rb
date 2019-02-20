#--------------------------
#
# @class RequirementsForHBrandingFeeNotDue
#
# @desc Responsibility: Knows when an H-Branding Fee is NOT due for a company (= the requirements are met)
#
#       This is a very simple class because the requirements are currently very simple.
#       The importance is that
#        it is the only place that code needs to be touched if the rules for
#        when an H-Branding fee is _not_ due are changed.
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/25/18
# @file requirements_for_h_branding_fee_not_due.rb
#
#--------------------------


class RequirementsForHBrandingFeeNotDue < AbstractOppositeRequirements

  def self.opposite_class
    RequirementsForHBrandingFeeDue
  end

end # RequirementsForHBrandingFeeNotDue
