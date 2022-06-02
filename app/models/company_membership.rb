# frozen_string_literal: true

# ---------------------------------------------------------------------------------------------------------------
#
# @class CompanyMembership
#
# @responsibility: Membership behavior specific to a membership for a Company
#
# ---------------------------------------------------------------------------------------------------------------

class CompanyMembership < AbstractMembership
  self.table_name = "memberships"
end
