# frozen_string_literal: true

module DbViews

  #--------------------------
  #
  # @class RefreshIfCoMembershipChanged
  #
  # @desc Responsibility: Common behavior (method) to refresh if the company membership status has changed
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   5/15/22
  #
  #--------------------------

  module RefreshIfCoMembershipChanged

    def company_status_changed(_company, _old_membership_state, _new_membership_state)
      Rails.logger.warn "\n\n Refreshing! "
      refresh
      Rails.logger.warn "\n\n Refreshed! \n\n"
    end
  end
end
