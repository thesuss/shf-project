# frozen_string_literal: true

module Reqs

  #--------------------------
  #
  # @class CompanyMembershipReqs
  #
  # @desc Responsibility: Knows what the membership requirements are for a Company
  #       - Given a company, it can respond true or false if membership requirements are met.
  #
  #       This is a very simple class because the requirements are currently very simple.
  #       The importance is that
  #       IT IS THE ONLY PLACE THAT CODE NEEDS TO BE TOUCHED IF MEMBERSHIP REQUIREMENTS ARE CHANGED.
  #
  #  Only 1 is needed for the system.
  #
  # @fixme What are the requirements, exactly? Must there be current_members? (company.current_members.any?)
  #
  # @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
  # @date   2022-05-20
  #
  #--------------------------

  class CompanyMembershipReqs < AbstractReqsForMembership

    def self.requirements_excluding_payments_met?(company, _date = Date.current)
      company.may_start_membership? &&
        company.information_complete?
    end
  end
end
