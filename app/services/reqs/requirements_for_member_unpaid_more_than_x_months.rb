# frozen_string_literal: true

module Reqs

  #--------------------------
  #
  # @class  RequirementsForMemberUnpaidMoreThanXMonths
  #
  # @desc Responsibility: Is the member exactly X months overdue from when they should have paid their Membership fee?
  #
  #  Only 1 is needed for the system.
  #
  # @author Ashley Engeund ( weedySeaDragon @ Github )
  # @date 2019-04-12
  # @file requirements_forrequirements_for_member_unpaid_for_x_months_.rb
  #
  #--------------------------
  class RequirementsForMemberUnpaidMoreThanXMonths < AbstractReqsForMember

    def self.has_expected_arguments?(args)
      super && args_have_keys?(args, [:num_months])
    end

    # This user's membership has lapsed and the expiration date is more than 6 months ago
    def self.requirements_met?(args)
      user = args[:entity]
      num_months = args[:num_months]
      return false unless Reqs::RequirementsForMembershipLapsed.requirements_met?({ entity: user })

      user.membership_expire_date < Time.zone.now.months_ago(num_months).to_date
    end
  end
end
