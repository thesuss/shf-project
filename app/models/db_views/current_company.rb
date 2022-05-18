# frozen_string_literal: true

require_relative 'refresh_if_membership_changed'
require_relative 'refresh_if_co_membership_changed'

module DbViews
  #--------------------------
  #
  # @class CurrentCompany
  #
  # @desc Responsibility: DB View for all companies that are current (in good standing; paid fees and have current members)
  #  This should be updated when the company status changes to current, or is no longer a current.
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   5/13/22
  #
  #--------------------------
  class CurrentCompany < AbstractDbMaterializedView
    extend RefreshIfMembershipChanged
    extend RefreshIfCoMembershipChanged

    belongs_to :company

  end
end

