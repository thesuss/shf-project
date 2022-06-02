# frozen_string_literal: true

module Memberships
  #--------------------------
  #
  # MembershipsManager
  #
  # @responsibility Manage memberships for a User; respond to queries about Memberships
  #
  # @fixme use @owner so that owner doesn't have to be passed in all the time.
  # @fixme should all methods be class methods?  delegate all instance methods to class methods?
  #
  # @todo refactor: pull out those that deal with the membership term (dates, length) into separate module or class
  # @todo should the methods checking about a date be in the Membership class?
  # @todo should this be renamed to MembershipsTermManager?  This is mostly about dates for the term
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2/16/21
  #
  #--------------------------
  #
  class MembershipsManager

    # status that means the membership will expire soon
    EXPIRES_SOON_STATUS = :expires_soon

    # Informational statuses are those that are _not_ used when determining the next status
    # (membership statuses that are transitioned from/to). They are just helpful information
    # presented to admins, users, members.
    #   @todo is there a better name for these?
    INFORMATIONAL_MEMBERSHIP_STATUSES = [EXPIRES_SOON_STATUS]

    # method to use for ordering memberships so that we can get the most recent one (i.e. the last one should be the most recent membership)
    MOST_RECENT_MEMBERSHIP_METHOD = :last_day

    # =============================================================================================

    # @fixme move to IsMember (that's where the statuses are -- with the state machine)
    def self.expires_soon_status
      EXPIRES_SOON_STATUS
    end

    # @fixme move to IsMember (that's where the statuses are -- with the state machine)
    def self.informational_statuses
      INFORMATIONAL_MEMBERSHIP_STATUSES
    end

    # @return [Symbol] method to use for sorting/getting the most recent membership
    def self.most_recent_membership_method
      MOST_RECENT_MEMBERSHIP_METHOD
    end

    # @return [Duration] - the number of days that a Member can renew early
    def self.days_can_renew_early
      AdminOnly::AppConfiguration.config_to_use.payment_too_soon_days.to_i.days
    end

    # @return [Duration] - the number of days after the end of a membership that a user can renew
    def self.grace_period
      AdminOnly::AppConfiguration.config_to_use.membership_expired_grace_period_duration
    end

    # @return [Integer] - the number of days before the end of a membership that means 'soon'
    #   as in 'your membership is expiring soon'
    def self.is_expiring_soon_amount
      AdminOnly::AppConfiguration.config_to_use.membership_expiring_soon_days.to_i.days
    end

    # Create an archived membership for every Membership for the entity
    #
    # @return [true] - true if everything succeeded, else errors will be raised by ArchivedMembershipFactory
    def self.create_archived_memberships_for(entity)
      entity.memberships.each do |membership|
        ArchivedMembershipFactory.create_from(membership)
      end
      true # no errors were raised
    end

    # @fixme implement here?  or call User method for now?
    def self.get_next_membership_number; end

    # Did the user pay for multiple Memberships in advance? Have they paid for a Membership beyond
    # the current Memberships?
    #
    # @fixme - rename to paid_in_advance?
    # @return [true,false]
    def self.user_paid_in_advance?(owner)
      owner.current_membership.present? &&
        owner.requirements_for_renewal
             .payment_requirements_met?(owner, owner.current_membership.last_day.to_date + 1.day)
    end

    # @todo move to IsMember ?
    # @return [nil, Membership] nil if no Memberships, else the one with the latest last day
    def self.most_recent_membership(user)
      memberships = user.memberships
      return nil if memberships.empty?

      memberships.order(most_recent_membership_method)&.last
    end

    # @return [nil, Membership] the membership that covers Date.current
    #   (is on or after first_day of the membership and on or before the last day of the membership)
    def self.current_membership(user)
      membership_on(user, Date.current)
    end

    # @return [nil, Membership] oldest Membership for the user where first_day <= this_date <= last_day
    #   return nil if no membership for the user exists with that condition
    def self.membership_on(user, this_date = Date.current)
      return nil if this_date.nil? || user.nil?

      Membership.for_owner_covering_date(user, this_date.to_date)&.first
    end

    # @fixme Since it only applies to a User move to UserChecklistManager since it has to do with _member guidelines checklist._ ?
    #
    # If the date agreed to was before the date when the Memberships were fully implemented,
    # the date is valid (= true)
    #
    # Else
    #  Membership guidelines can be agreed to during the valid time for renewing or, if the membership
    #  is not a renewal, they can be agreed to on or before the first day of the membership.
    #  (You have to agree to the guidelines before you can pay for a membership and create (instantiate) one.)
    #
    #
    # @param membership [Membership]
    # @param date [Date] the date to validate
    # @return [true,false] is the given date valid for when the user could have agreed to the membership guidelines?
    #   If no, then even if they agreed to them on that date, they don't count as completed; they need to agree again.
    def self.valid_membership_guidelines_agreement_date?(membership, date)
      date_as_date = date.to_date # ensure we are comparing Dates (vs. Date and Times)

      return true if date_as_date < UserChecklistManager.membership_guidelines_required_date.to_date

      if date_as_date <= membership.first_day.to_date
        previous_membership = membership.owner.memberships.reject { |m| m == membership }.max_by(&:last_day)
        if previous_membership.present?
          date_as_date >= previous_membership.last_day.to_date - days_can_renew_early
        else
          true
        end
      else
        false
      end
    end

    # ---------------------------------------------------------------------------------

    # @return [nil, Membership] call the class method of the same name (manual delegation)
    def most_recent_membership(user)
      self.class.most_recent_membership(user)
    end

    # @return [Symbol] call the class method of the same name (manual delegation)
    def most_recent_membership_method
      self.class.most_recent_membership_method
    end

    # Does a user have a membership that has not expired as of the given date
    # Note this does not determine if payments were made, requirements were met, etc.
    # @return [true, false]
    def has_membership_on?(user, this_date)
      return false if this_date.nil?

      Membership.for_owner_covering_date(user, this_date.to_date).exists?
    end

    # @return [nil, Membership] call class method of the same name (manual delegation)
    def membership_on(user, this_date = Date.current)
      self.class.membership_on(user, this_date.to_date)
    end

    # The membership term has expired, but are they still within a 'grace period'?
    # @return [true, false]
    def membership_in_grace_period?(user,
                                    this_date = Date.current,
                                    membership: most_recent_membership(user))
      return false if membership.nil?

      date_in_grace_period?(this_date.to_date, last_day: membership.last_day.to_date)
    end

    # Is the given date within a grace period for a time period starting with _last_day_ and a duration of _grace_period_?
    # @param [Date] this_date The given date to check
    # @param [Date] last_day The start of the time period (e.g. the last day of a Membership)
    # @param [Integer] grace_days The duration of the grace period, in days
    # @return [true, false]
    def date_in_grace_period?(this_date = Date.current,
                              last_day: Date.current,
                              grace_days: grace_period)
      this_date.to_date > last_day.to_date &&
        this_date.to_date <= (last_day.to_date + grace_days)
    end

    # Is the given date after the end of the grace period for the user's membership?
    #
    # @param [AbstractMember] user The entity that owns the membership
    # @param [Date] this_date The given date to check. (default = Date.current)
    # @param [Membership, nil] membership The membership to check (default is the user's most_recent_membership)
    # @return [true, false]
    def date_after_grace_period_end?(user,
                                     this_date = Date.current,
                                     membership: most_recent_membership(user))
      return false if membership.nil?

      this_date.to_date > (membership.last_day.to_date + grace_period)
    end

    # @return [Integer] call the class method of the same name (manual delegation)
    def grace_period
      self.class.grace_period
    end

    # Is today a valid renewal date for the user?
    # @return [true, false]
    def today_is_valid_renewal_date?(user)
      valid_renewal_date?(user, Date.current)
    end

    # Is this a valid date for renewing?
    # This just checks the membership status and dates about renewal,
    #   not any requirements for renewing a membership.
    #
    # @return [true, false]
    def valid_renewal_date?(user, this_date = Date.current)
      return false unless user.in_grace_period? || has_membership_on?(user, this_date)

      this_date_as_date = this_date.to_date # ensure we are comparing Dates (vs. Date and Times)
      last_day = most_recent_membership_last_day(user).to_date
      if this_date_as_date <= last_day
        this_date_as_date >= (last_day - days_can_renew_early)
      else
        membership_in_grace_period?(user, this_date_as_date)
      end
    end

    # The first day of the user's most recent Membership.  return nil if there is no most recent Membership
    # @todo move to IsMember ?
    # @return [nil, Date]
    def most_recent_membership_first_day(user)
      most_recent_membership(user)&.first_day&.to_date
    end

    # The last day of the user's most recent Membership.  return nil if there is no most recent Membership
    # @todo move to IsMember ?
    # @return [nil, Date]
    def most_recent_membership_last_day(user)
      most_recent_membership(user)&.last_day&.to_date
    end

    # @return [Duration] calls the class method of the same name (manual delegation)
    def days_can_renew_early
      self.class.days_can_renew_early
    end

    # Is the Membership expiring soon?
    #  true if the user is a member
    #     AND today is on or after the (last day - the expiring soon amount)
    #
    # @param [Member] owner the entity that owns the membership
    # @param [Membership, nil] membership The membership to check. default is the user's most recent membership
    # @return [true, false]
    def expires_soon?(owner, membership = most_recent_membership(owner))
      owner.current_member? && membership.present? && ((membership.last_day.to_date - self.class.is_expiring_soon_amount) <= Date.current)
    end

    def expires_soon_status
      self.class.expires_soon_status
    end

    def create_archived_memberships_for(entity)
      self.class.create_archived_memberships_for(entity)
    end

  end
end
