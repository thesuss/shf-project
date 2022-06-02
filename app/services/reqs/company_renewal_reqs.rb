# frozen_string_literal: true

require_relative 'renewal_with_fail_info'

module Reqs

  #--------------------------
  #
  # @class CompanyRenewalReqs
  #
  # @responsibility Knows what the requirements are for a Company to renew membership.
  #
  #   Given a company, it can respond true or false if the membership renewal requirements are met.
  #   Note that it is _not_ the responsibility of this class to know if the given member has been
  #   unpaid so long that they cannot simply 'renew' but must re-apply.
  #
  #  This is a very simple class because the requirements are currently very simple.
  #  The importance is that
  #   IT IS THE ONLY PLACE THAT CODE NEEDS TO BE TOUCHED IF MEMBERSHIP REQUIREMENTS ARE CHANGED.
  #
  #  Only 1 is needed for the system.
  #
  #
  # @fixme What are the renewals requirements for a Company?
  #
  # @todo Make this a Singleton so that we don't need to use a class variable to store the failed requirements info
  #
  # @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
  # @date   12/08/20
  #
  #--------------------------

  class CompanyRenewalReqs < AbstractReqsForMembership
    include RenewalWithFailInfo

    @failed_requirements = []

    # check all requirements except the payment.
    # Wrap each requirement method in record_requirement_failure so we can record the reason why
    # the requirement failed.
    #
    # @return [true, false]
    def self.requirements_excluding_payments_met?(company, date = Date.current)
      reset_failed_requirements
      record_requirement_failure(company, :may_renew?, nil, "cannot renew based on the current membership status (status: #{company.membership_status})") &
        record_requirement_failure(company, :valid_date_for_renewal?, date, "#{date} is not a valid renewal date (#{current_membership_short_str(company)})")
    end

  end
end
