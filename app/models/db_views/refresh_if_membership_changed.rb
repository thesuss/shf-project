# frozen_string_literal: true

module DbViews

  #--------------------------
  #
  # @class RefreshIfMembershipChanged
  #
  # @desc Responsibility: Common behavior (method) to refresh if the membership status has changed
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   5/15/22
  #
  #--------------------------

  module RefreshIfMembershipChanged

    # Only refresh the the membership status has changed from :current_member or to :current_member.
    def membership_status_changed(_user, old_membership_state, new_membership_state)
      Rails.logger.warn "\n\n Refreshing! "
      refresh if old_membership_state == :current_member || new_membership_state == :current_member
      Rails.logger.warn "\n\n Refreshed! \n\n"
    end
  end
end
