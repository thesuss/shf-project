# frozen_string_literal: true

module Reqs

  #--------------------------
  #
  # @class RequirementsForMembershipLapsed
  #
  # @desc Responsibility: Knows if a membership has lapsed
  #
  #       This is a very simple class because the requirements are currently very simple.
  #       The importance is that
  #        it is the only place that code needs to be touched if the rules for
  #        if a Membership has lapsed
  #
  #  Only 1 is needed for the system.
  #
  # @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
  # @date   2019-01-26
  # @file requirements_membership_lapsed.rb
  #
  #--------------------------
  #
  class RequirementsForMembershipLapsed < AbstractReqsForMember

    # A Membership has lapsed if
    #   they are now in the (renewal) grace period
    # OR
    #   they are a former member
    def self.requirements_met?(args)
      entity = args[:entity]
      entity.in_grace_period? || entity.former_member?
    end

  end
end
