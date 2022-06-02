# frozen_string_literal: true

require 'observer'

#--------------------------
#
# @module IsMember
#
# @desc Responsibility: everything needed for being a member in SHF.
#   - transitions between membership states, and when it is/isn't valid to do so (AASM)
#   - does membership term calculations and queries
#   - can get the current membership
#   - can get the most recent membership (even if it's not a current membership)
#   - can archive memberships
#   - can get the next available membership number
#   - is observable (can notify oberservers of changes)
#
#  What most non-nerdy, non-analytic people would call a "membership" is generally a "membership term"...
#
#  This includes a state machine for dealing with the current membership state; uses the AASM (Acts As State Machine) gem.
#  Note that in order to use AASM in a module, it must be manually included (see the code below).
#
#  This assumes that the database table has a column named 'membership_status' (used by AASM below).
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   5/20/22
#--------------------------

module IsMember
  include HasProofOfMembershipImage
  include Observable

  # ==========================================================================================================
  module ClassMethods

    # encapsulate how to get a list of all states as symbols
    def membership_statuses
      aasm.states.map(&:name)
    end

    def memberships_manager_class
      Memberships::MembershipsManager
    end

    # All memberships statuses _and_ 'expires_soon' ('Expires soon' is not a "real" status. It is not
    #   used to track or transition to/from statuses, but it is informative to show to admins and
    #   members.  It is just _informational_.
    def membership_statuses_incl_informational
      aasm.states.map(&:name) + memberships_manager_class.informational_statuses
    end
  end

  # ==========================================================================================================

  # ----------------------------------------------------------------------------------------------
  # Act As State Machine (AASM)

  #  Must include this manually so that AASM can be used in a module (which is then included in other classes).
  def self.included(klass)
    klass.extend(ClassMethods)

    klass.include AASM

    klass.aasm column: 'membership_status' do
      state :not_a_member, initial: true
      state :current_member
      state :in_grace_period
      state :former_member

      after_all_transitions :membership_changed

      # You can pass the (keyword) arguments
      #    date: <Date>
      #    send_email: [true | false]
      # to methods that are called
      # @see https://github.com/aasm/aasm#callbacks

      event :start_membership do
        transitions from: [:not_a_member, :current_member, :former_member], to: :current_member, after: proc { |*args| start_membership_on(*args) }
      end

      event :renew do
        transitions from: [:current_member, :in_grace_period], to: :current_member, after: proc { |*args| renew_membership_on(*args) }
      end

      event :start_grace_period do
        transitions from: :current_member, to: :in_grace_period, after: proc { |*args| enter_grace_period(*args) }
      end

      event :make_former_member do
        transitions from: :in_grace_period, to: :former_member, after: proc { |*args| become_former_member(*args) }
      end

      event :restore_membership do
        transitions from: :in_grace_period, to: :current_member, after: proc { |*args| restore_from_grace_period(*args) }
      end
    end
  end

  def membership_changed
    changed # have to set the Observer status to changed so we can notify
    notify_observers(self, aasm.from_state, aasm.to_state)
    # This can be used to write info to logs
    @membership_changed_info = "membership status changed from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
  end

  NEW_ACTION_NAME = 'New'
  RENEW_ACTION_NAME = 'Renew'
  ENTER_GRACEPERIOD_ACTION_NAME = 'EnterGracePeriod'
  BECOME_FORMER_ACTION_NAME = 'BecomeFormer'
  RESTORE_FROM_GRACEPERIOD_ACTION_NAME = 'Restore'

  # will raise a NameError if it cannot find the actions_class with .constantize
  def start_membership_on(date: Date.current, send_email: true)
    do_actions(NEW_ACTION_NAME, first_day: date, send_email: send_email)
  end

  # will raise a NameError if it cannot find the actions_class with .constantize
  def renew_membership_on(date: Date.current, send_email: true)
    do_actions(RENEW_ACTION_NAME, first_day: date, send_email: send_email)
  end

  # will raise a NameError if it cannot find the actions_class with .constantize
  def enter_grace_period(date: Date.current, send_email: true)
    do_actions(ENTER_GRACEPERIOD_ACTION_NAME, first_day: date, send_email: send_email)
  end

  # will raise a NameError if it cannot find the actions_class with .constantize
  def become_former_member(date: Date.current, send_email: true)
    do_actions(BECOME_FORMER_ACTION_NAME, first_day: date, send_email: send_email)
    # Memberships::BecomeFormerUserMemberActions.for_entity(self, first_day: date, send_email: send_email)
  end

  # will raise a NameError if it cannot find the actions_class with .constantize
  def restore_from_grace_period(date: Date.current, send_email: true)
    do_actions(RESTORE_FROM_GRACEPERIOD_ACTION_NAME, first_day: date, send_email: send_email)
    # Memberships::RestoreUserMemberActions.for_entity(self, send_email: send_email)
  end

  def actions_class_name(action = '')
    "Memberships::#{action.tr(' ', '_').camelize}#{self.class}MemberActions"
  end

  def do_actions(action_name, first_day: Date.current, send_email: should_send_email)
    actions_class = actions_class_name(action_name).constantize
    actions_class.for_entity(self, first_day: first_day, send_email: send_email)
  end

  # ----------------------------------------------------------------------------------------------------------

  # Make this a current member.
  # Do nothing if already a current member.
  # If not a current member, start a membership
  # @todo Is this used?  Should it be used? Should start_membership_on be used instead? (if so, add the guard)
  def make_current_member
    start_membership_on(date: Date.current) unless current_member?
  end

  # Check to see if this member was in good standing on a given date
  def member_in_good_standing?(date = Date.current)
    requirements_for_membership.satisfied?(self, date: date)
  end

  def memberships_manager
    @memberships_manager ||= self.class.memberships_manager_class.new
  end

  # @return [nil | Membership] - the oldest membership that covers today (Date.current)
  #   nil if no memberships are found
  # @todo delegate to memberships manager
  def current_membership
    memberships_manager.membership_on(self, Date.current)
  end

  # @return [nil, Membership] the most recent membership (the current membership may have expired)
  # @todo delegate to memberships manager
  def most_recent_membership
    memberships_manager.most_recent_membership(self)
  end

  # Returns the first day of the most recent membership, where "most recent" means the one that is current
  # @todo delegate to memberships manager
  def membership_first_day
    memberships_manager.most_recent_membership_first_day(self)
  end

  # Returns the last day of the most recent membership, where "most recent" means the one that is current
  # @todo delegate to memberships manager
  def membership_last_day
    memberships_manager.most_recent_membership_last_day(self)
  end

  # @todo delegate to memberships manager
  def membership_expires_soon?(this_membership = most_recent_membership)
    memberships_manager.expires_soon?(self, this_membership)
  end

  # The membership term has expired, but are they still within a 'grace period'?
  # @todo delegate to memberships manager
  def membership_expired_in_grace_period?(this_date = Date.current)
    memberships_manager.membership_in_grace_period?(self, this_date)
  end

  # the date is after the renewal grace period;
  # @todo delegate to memberships manager
  def membership_past_grace_period_end?(this_date = Date.current)
    memberships_manager.date_after_grace_period_end?(self, this_date)
  end

  # @return [Symbol] - the membership status.
  # If the membership status is current AND the given Date
  # is on or after the date that it expires soon, return the informational status 'expires_soon'
  # @todo delegate to memberships manager
  def membership_status_incl_informational(this_membership = most_recent_membership)
    if membership_expires_soon?(this_membership)
      memberships_manager.expires_soon_status
    else
      membership_status
    end
  end

  # @todo delegate to memberships manager
  def today_is_valid_renewal_date?
    memberships_manager.today_is_valid_renewal_date?(self)
  end

  # @todo delegate to memberships manager
  def valid_date_for_renewal?(this_date = Date.current)
    memberships_manager.valid_renewal_date?(self, this_date)
  end

  #  @todo delegate to memberships manager
  def archive_memberships
    memberships_manager.create_archived_memberships_for(self)
  end

  def membership_last_day_has_changed
    clear_proof_of_membership_image_cache
  end

  # ==========================================================================================================

  private

  # @todo is this really the right place? Should MembershipManager do this?
  def get_next_membership_number
    self.class.connection.execute("SELECT nextval('membership_number_seq')").getvalue(0, 0).to_s
  end
end
