# frozen_string_literal: true

# ---------------------------------------------------------------------------------------------------------------
#
# @class AbstractMembership
#
# @responsibility: parent class for all memberships
#
# @todo membership has_many :payments
#
# ---------------------------------------------------------------------------------------------------------------
#
class AbstractMembership < ApplicationRecord
  self.abstract_class = true

  belongs_to :owner, polymorphic: true

  # BUSINESS RULE: Definition of a first membership
  #   A 'first membership' is a membership for a owner only if there are no past memberships within
  #     2 years
  #   If a owner had a past membership within the previous _2 years_, then they are considered a
  #    "former member."  This may mean that there are different behaviours/actions/expectations.
  #    (Ex: a different welcome email might be sent out.)
  #
  FIRST_MEMBERSHIP_TIMELIMIT = 2.years # @todo get from AppConfiguration  Does this apply to Users _and_ Companies? or just Users?


  # @fixme use observer/notifier instead; just let observers know that the last day has changed.
  after_save :membership_last_day_has_changed, if: proc { saved_change_to_last_day? }

  # =============================================================================================

  # @return [ActiveRecord::Relation] - all Memberships that were active on the given date,
  #   ordered by the last_day.  "active" means the first day was on or before the given date
  #   AND the last_day was on or after the given date.
  def self.covering_date(date = Date.current)
    where('first_day <= ?', date.to_date)
      .where('last_day >= ?', date.to_date)
      .order(last_day: :asc, id: :asc)
  end

  def self.for_owner_covering_date(owner, date = Date.current)
    where(owner: owner).covering_date(date.to_date)
  end

  def self.starting_on_or_after(first_day = Date.current)
    where('first_day >= ?', first_day.to_date)
  end

  # @return [ActiveRecord::Relation] - a list of any memberships for the owner
  #   that started on or after the first_day
  def self.for_owner_starting_on_or_after(owner, first_day = Date.current)
    where(owner: owner).starting_on_or_after(first_day.to_date)
  end

  # @return [ActiveSupport::Duration] - the membership term length as a Duration
  def self.term_length
    AdminOnly::AppConfiguration.config_to_use.membership_term_duration
  end

  def self.first_day_from_last(last_day = Date.current)
    # last_day - term_length + 1.day
    other_day_from(last_day.to_date, -1)
  end

  def self.last_day_from_first(first_day = Date.current)
    # first_day + term_length - 1.day
    other_day_from(first_day.to_date, 1)
  end

  def self.other_day_from(date, multiplier = 1)
    date.to_date + (multiplier * (term_length - 1.day))
  end

  # @fixme applies only to User? or does this apply to a Company too?
  def self.first_membership_time_period
    FIRST_MEMBERSHIP_TIMELIMIT
  end

  # -----------------------------------------------------------------------------------------------

  def set_first_day_and_last(first_day: Date.current, last_day: (self.class.other_day_from(first_day)))
    update(first_day: first_day.to_date, last_day: last_day.to_date)
  end

  # @return - true if this is the first membership ever for the owner,
  #   where the definition of a first membership is (see above in the class block comment)
  #   Ignore this membership (self)
  def first_membership?(time_period: FIRST_MEMBERSHIP_TIMELIMIT)
    (any_membership_within(time_period).reject { |membership| membership == self }).empty?
  end

  # @return [ActiveRecord::Relation] - a list of any memberships for the owner
  #   that started on or after the (starting date - time_period)
  def any_membership_within(time_period = FIRST_MEMBERSHIP_TIMELIMIT, starting_date: Date.current)
    self.class.for_owner_starting_on_or_after(owner, starting_date.to_date - time_period)
  end

  # @fixme  Does this really belong here?
  def membership_last_day_has_changed
    owner&.membership_last_day_has_changed
  end
end
