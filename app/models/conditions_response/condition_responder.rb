#!/usr/bin/ruby



class ConditionResponderError < StandardError
end

class TimingNotValidError < ConditionResponderError
end

class ExpectedTimingsCannotBeEmptyError < ConditionResponderError
end


#--------------------------
#
# @class ConditionResponder
#
# @desc Responsibility: Take a condition and some configuration information
# and _responds_ (handles) the condition.
#
# This might mean looking thru members and sending them emails if
# some particular condition is met, for example.
#
# Although this class is nearly empty right now, it is here to clarify
# the overall design.
#
# TODO: ? rename to ConditionHandler - because it _handles_ conditions, it
# doesn't respond _to_ them or _with_ them (it doesn't send a Condition to anything.
#  It queries them and does it's own thing)
#
# @date   2018-12-13
#
# @file condition_responder.rb
#
#--------------------------
class ConditionResponder

  Timing = Symbol

  TIMING_BEFORE    = :before
  TIMING_AFTER     = :after
  TIMING_ON        = :on
  TIMING_EVERY_DAY = :every_day
  TIMING_DAY_OF_MONTH = :day_of_month

  ALL_TIMINGS = [TIMING_BEFORE, TIMING_AFTER, TIMING_ON, TIMING_EVERY_DAY, TIMING_DAY_OF_MONTH]


  DEFAULT_TIMING = TIMING_ON
  DEFAULT_CONFIG = {}


  # All subclasses must implement this class. This is how they respond to/
  #  handle a condition.
  #
  # @param condition [Condition] - the Condition that must be responded do
  # @param log [ActivityLog] - the log file to write to
  def self.condition_response(_condition, _log, use_slack_notification: true)
    raise NoMethodError, "Subclass must define the #{__method__} method", caller
  end


  # Get the configuration from the condition
  # @param [Condition]
  # @return [Config] the condition.config,
  #                 or the DEFAULT_CONFIG if there is no condition
  def self.get_config(condition)
    condition.nil? ? DEFAULT_CONFIG : condition.config
  end


  # Get the timing from the condition
  # @param condition [Condition]
  # @return timing [Timing] - condition.timing if condition is nil,
  #                           return the DEFAULT_TIMING
  def self.get_timing(condition)
    condition.nil? ? DEFAULT_TIMING : condition.timing.to_sym
  end


  # Determine the number of days today is _away_from_ this date.
  # The :timing is whether we are calculating the number of days
  # _before_, _after_, or _on_ this day, starting from today.
  #
  # @param this_date [Date] - the date to compare to today
  # @param timing [Timing] - which 'direction' (before, after, on) to compare to today
  # @return [Integer] - the number of days away from today, based on our :timing
  def self.days_today_is_away_from(this_date, timing)
    days_1st_date_is_from_2nd(Date.current, this_date, timing)
  end


  # Determine the number of days :a_date is _away_from_ :second_date.
  # The :timing is whether we are calculating the number of days
  # _before_, _after_, or _on_ this day, starting from :a_date.
  #
  # @param a_date [Date] - the starting date
  # @param second_date [Date] - the date to compare to :a_date
  # @param timing [Timing] - which 'direction' (before, after, on) to compare to :a_date
  # @return [Integer] - the number of days separating the two dates, based on the :timing
  def self.days_1st_date_is_from_2nd(a_date, second_date, timing)

    day_num_to_check = 0 # default value

    # We use .to_date to ensure that we're comparing and working with Dates, not Times, etc.
    # If calling .to_date throws an exception, that's an exception that should be raised.

    if timing_is_before?(timing)
      # number of days that a_date is _before_ second_date
      day_num_to_check = second_date.to_date - a_date.to_date

    elsif timing_is_after?(timing)
      # number of days that a_date is _after_ second_date
      day_num_to_check = a_date.to_date - second_date.to_date
    end

    day_num_to_check.to_i
  end


  def self.timing_is_before?(timing)
    timing == TIMING_BEFORE
  end


  def self.timing_is_after?(timing)
    timing == TIMING_AFTER
  end


  def self.timing_is_on?(timing)
    timing == TIMING_ON
  end


  def self.timing_is_every_day?(timing)
    timing == TIMING_EVERY_DAY
  end


  def self.timing_is_day_of_month?(timing)
    timing == TIMING_DAY_OF_MONTH
  end


  # True if the timing is every day
  # OR if it is set to a day of the month and today is that day
  def self.timing_matches_today?(timing, config)
    timing_is_every_day?(timing) || today_is_timing_day_of_month?(timing, config)
  end


  # True if the timing is for the day of a month
  # and today is the day of the month specified in the config
  def self.today_is_timing_day_of_month?(timing, config)
    self.timing_is_day_of_month?(timing) &&
        config.fetch(:days, false) &&
        config[:days].include?(Date.current.day)
  end


  # keep this for backwards compatibility for now.  TODO: change usages to .validate_timing
  def self.confirm_correct_timing(timing, expected_timing, log)
    validate_timing(timing, [expected_timing], log)
  end


  # Validates that the timing is in the list of valid timings.
  # If it is not, it logs an error and raises and exception
  #
  # @param timing [Timing] - the timing to validate
  # @param expected_timings [Array] - list of valid timings
  # @param log [Log] - the log to record the error to
  #
  def self.validate_timing(timing, expected_timings = [], log)

    if expected_timings.empty?
      msg = "List of expected timings cannot be empty"
      log.record('error', msg)
      raise ExpectedTimingsCannotBeEmptyError, msg
    end

    valid_timings = expected_timings.is_a?(Enumerable) ? expected_timings : [expected_timings]

    unless valid_timings.include? timing
      msg = "Received timing :#{timing} which is not in list of expected timings: #{valid_timings}"
      log.record('error', msg)
      raise TimingNotValidError, msg
    end
  end


  def self.all_timings
    ALL_TIMINGS
  end


  def self.default_timing
    DEFAULT_TIMING
  end


  def self.timing_on
    TIMING_ON
  end


  def self.timing_before
    TIMING_BEFORE
  end


  def self.timing_after
    TIMING_AFTER
  end


  def self.timing_every_day
    TIMING_EVERY_DAY
  end


  def self.timing_day_of_month
    TIMING_DAY_OF_MONTH
  end

end # ConditionResponder
