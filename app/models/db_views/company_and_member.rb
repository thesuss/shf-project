# frozen_string_literal: true

require_relative 'refresh_if_membership_changed'
require_relative 'refresh_if_co_membership_changed'

module DbViews
  #--------------------------
  #
  # @class CompanyAndMember
  #
  # @desc Responsibility: Company and current member (database materialized view)
  #  This should be updated when a user becomes a current member, or is no longer a current member.
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   5/13/22
  #
  #--------------------------
  class CompanyAndMember < AbstractDbMaterializedView
    extend RefreshIfMembershipChanged
    extend RefreshIfCoMembershipChanged

    belongs_to :member, class_name: "User", foreign_key: 'user_id'
    belongs_to :company, foreign_key: 'company_id'

  end
end

