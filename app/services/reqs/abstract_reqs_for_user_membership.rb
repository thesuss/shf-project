# frozen_string_literal: true

module Reqs

  #--------------------------
  #
  # AbstractReqsForUserMembership
  #
  # @responsibility Knows what the membership requirements are for a User.
  #   Given a user, it can respond true or false if membership requirements are met.
  #
  # This is a very simple class because the requirements are currently very simple.
  # The importance is that
  #  IT IS THE ONLY PLACE THAT CODE NEEDS TO BE TOUCHED IF MEMBERSHIP REQUIREMENTS ARE CHANGED.
  #
  # Only 1 is needed for the system.
  #
  #
  # @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
  # @date   2022-05-20
  #
  #--------------------------

  class AbstractReqsForUserMembership < AbstractReqsForMembership

    # Has the entity completed the membership guidelines checklist?
    # @return [True,False]
    def self.membership_guidelines_checklist_done?(user)
      user.membership_guidelines_checklist_done?
    end
  end
end
