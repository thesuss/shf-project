# frozen_string_literal: true

require_relative 'refresh_if_membership_changed'

module DbViews
  #--------------------------
  #
  # @class DbViewHasUser
  #
  # @desc Responsibility: Member and business category (database materialized view)
  #  This should be updated when a user becomes a current member, is no longer a current member, or
  #  gains or loses an approved business category.
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   5/13/22
  #
  #--------------------------
  class MemberAndCategory < AbstractDbMaterializedView
    extend RefreshIfMembershipChanged

    belongs_to :member, class_name: "User", foreign_key: 'user_id'
    belongs_to :business_category, foreign_key: "category_id"
    belongs_to :application, class_name: "ShfApplication", foreign_key: "application_id"

  end
end
