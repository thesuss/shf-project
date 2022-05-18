# frozen_string_literal: true

require_relative 'refresh_if_membership_changed'
require_relative 'refresh_if_co_membership_changed'

module DbViews
  #--------------------------
  #
  # @class CompanyAndCategory
  #
  # @desc Responsibility: Company and business category (database materialized view)
  #  This should be updated when a user becomes a current member, is no longer a current member, or
  #  gains or loses an approved business category.
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   5/13/22
  #
  #--------------------------
  class CompanyAndCategory < AbstractDbMaterializedView
    extend RefreshIfMembershipChanged
    extend RefreshIfCoMembershipChanged

    belongs_to :company
    belongs_to :business_category, foreign_key: "category_id"

  end
end
