require 'rails_helper'

require 'shared_context/activity_logger'


RSpec.describe ConditionResponder, type: :model do
  include_context 'create logger'


  describe '.condition_response' do

    it 'raises NoMethodError (must be defined by subclasses)' do

      condition    = Condition.create(class_name: 'MembershipExpireAlert',
                                      timing:     'before',
                                      config:     { days: [60, 30, 14, 2] })

      expect { described_class.condition_response(condition, log) }.to raise_exception NoMethodError
    end

  end


  it 'DEFAULT_TIMING is :on' do
    expect(ConditionResponder::DEFAULT_TIMING).to eq :on
  end

  describe '.get_timing' do

    it 'always returns a symbol' do
      expect(ConditionResponder.get_timing(create(:condition, timing: :blorf))).to eq(:blorf)
    end

    context 'condition is nil' do
      it 'returns the DEFAULT TIMING' do
        expect(ConditionResponder.get_timing(nil)).to eq ConditionResponder::DEFAULT_TIMING
      end
    end

    context 'condition is not nil' do
      it 'returns the timing from the condition if condition is not nil' do
        expect(ConditionResponder.get_timing(create(:condition, timing: :flurb))).to eq(:flurb)
      end
    end

  end


  it 'DEFAULT_CONFIG is an empty Hash' do
    default_c = ConditionResponder::DEFAULT_CONFIG
    expect(default_c).to be_a Hash
    expect(default_c).to be_empty
  end

  describe '.get_config' do

    context 'condition is nil' do
      it 'returns the DEFAULT_CONFIG TIMING' do
        expect(ConditionResponder.get_config(nil)).to eq ConditionResponder::DEFAULT_CONFIG
      end
    end

    context 'condition is not nil' do
      it 'returns the timing from the condition if condition is not nil' do
        expect(ConditionResponder.get_config(create(:condition, config: {mertz: 732} ))).to eq({mertz: 732})
      end
    end

  end



  describe '.days_a_date_is_away_from(a_date, timing, some_date)' do

    let(:nov_30) { Date.new(2018, 11, 30) }
    let(:dec_1)  { Date.new(2018, 12,  1) }
    let(:dec_2)  { Date.new(2018, 12,  2) }

    around(:each) do |example|
      Timecop.freeze(dec_1)
      example.run
      Timecop.return
    end


    context 'timing is before' do

      let(:timing_before) { ConditionResponder::TIMING_BEFORE }

      it '1st is 1 day before 2nd date  = 1' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(nov_30, dec_1, timing_before)).to eq 1
      end

      it '1st = 2nd date  == 0' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_1, dec_1, timing_before)).to eq 0
      end

      it '1st date is 1 day after 2nd date  = -1' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_2, dec_1, timing_before)).to eq -1
      end

    end

    context 'timing is after' do

      let(:timing_after) { ConditionResponder::TIMING_AFTER }

      it '1st is 1 day before 2nd date  = -1' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(nov_30, dec_1, timing_after)).to eq -1
      end

      it '1st = 2nd date  == 0' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_1, dec_1, timing_after)).to eq 0
      end

      it '1st date is 1 day after 2nd date  = 1' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_2, dec_1, timing_after)).to eq 1
      end

    end


    context 'timing is on (always returns 0 days away; this means always check on the 2nd date no matter how many days away)' do

      let(:timing_on) { ConditionResponder::TIMING_ON }

      it '2nd date is 1 day before the date = 0' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_1, nov_30, timing_on)).to eq 0
      end

      it '2nd date is == the date = 0' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_1, dec_1, timing_on)).to eq 0
      end

      it '2nd date is 1 day after the date = 0' do
        expect(ConditionResponder.days_1st_date_is_from_2nd(dec_1, dec_2, timing_on)).to eq 0
      end

    end

  end


  describe '.days_today_is_away_from(timing, some_date)' do

    let(:nov_30) { Date.new(2018, 11, 30) }
    let(:dec_1)  { Date.new(2018, 12,  1) }
    let(:dec_2)  { Date.new(2018, 12,  2) }

    around(:each) do |example|
      Timecop.freeze(dec_1)
      example.run
      Timecop.return
    end


    context 'timing is before' do

      let(:timing_before) { ConditionResponder::TIMING_BEFORE }

      it 'today is 1 day before the date = ConditionResponder.days_1st_date_is_from_2nd(Date.current, nov_30, timing_before)' do
        expect(ConditionResponder.days_today_is_away_from(nov_30, timing_before)).to eq ConditionResponder.days_1st_date_is_from_2nd(dec_1, nov_30, timing_before)
      end

      it 'today = the date = ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_1, timing_before)' do
        expect(ConditionResponder.days_today_is_away_from(dec_1, timing_before)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_1, timing_before)
      end

      it 'today is 1 day after the date = ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_2, timing_before)' do
        expect(ConditionResponder.days_today_is_away_from(dec_2, timing_before)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_2, timing_before)
      end

    end

    context 'timing is after' do

      let(:timing_after) { ConditionResponder::TIMING_AFTER }

      it 'today is 1 day after the date = ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_2, timing_after)' do
        expect(ConditionResponder.days_today_is_away_from(dec_2, timing_after)).to eq  ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_2, timing_after)
      end

      it 'date is on today = ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_1, timing_after)' do
        expect(ConditionResponder.days_today_is_away_from(dec_1, timing_after)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_1, timing_after)
      end

      it 'today is 1 day before the date = ConditionResponder.days_1st_date_is_from_2nd(Date.current, nov_30, timing_after)' do
        expect(ConditionResponder.days_today_is_away_from(nov_30, timing_after)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, nov_30, timing_after)
      end

    end


    context 'timing is on (always returns 0 days away; this means always check on today)' do

      let(:timing_on) { ConditionResponder::TIMING_ON }

      it 'date is 1 day before today = ConditionResponder.days_1st_date_is_from_2nd(Date.current, nov_30, timing_on)' do
        expect(ConditionResponder.days_today_is_away_from(nov_30, timing_on)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, nov_30, timing_on)
      end

      it 'date is on today = ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_1, timing_on)' do
        expect(ConditionResponder.days_today_is_away_from(dec_1, timing_on)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_1, timing_on)
      end

      it 'date is 1 day after today = ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_2, timing_on)' do
        expect(ConditionResponder.days_today_is_away_from(dec_2, timing_on)).to eq ConditionResponder.days_1st_date_is_from_2nd(Date.current, dec_2, timing_on)
      end

    end

  end

  context 'timing predicate methods' do

    let(:condition) { build(:condition) }
    let(:timing) { ConditionResponder.get_timing(condition) }

    describe '.timing_is_before?(timing)' do
      it 'returns true if timing == :before' do
        condition.timing = ConditionResponder::TIMING_BEFORE
        expect(ConditionResponder.timing_is_before?(timing)).to be true
      end

      it 'returns false otherwise' do
        condition.timing = ConditionResponder::DEFAULT_TIMING
        expect(ConditionResponder.timing_is_before?(timing)).to be false
      end
    end


    describe '.timing_is_after?(timing)' do
      it 'returns true if timing == :after' do
        condition.timing = ConditionResponder::TIMING_AFTER
        expect(ConditionResponder.timing_is_after?(timing)).to be true
      end

      it 'returns false otherwise' do
        condition.timing = ConditionResponder::DEFAULT_TIMING
        expect(ConditionResponder.timing_is_after?(timing)).to be false
      end
    end


    describe '.timing_is_on?(timing)' do
      it 'returns true if timing == :on' do
        condition.timing = ConditionResponder::TIMING_ON
        expect(ConditionResponder.timing_is_on?(timing)).to be true
      end

      it 'returns false otherwise' do
        condition.timing = :not_on
        expect(ConditionResponder.timing_is_on?(timing)).to be false
      end
    end


    describe '.timing_is_every_day?(timing)' do

      it 'returns true if timing == :every_day' do
        condition.timing = ConditionResponder::TIMING_EVERY_DAY
        expect(ConditionResponder.timing_is_every_day?(timing)).to be true
      end

      it 'returns false otherwise' do
        condition.timing = ConditionResponder::DEFAULT_TIMING
        expect(ConditionResponder.timing_is_every_day?(timing)).to be false
      end

    end

    describe '.timing_is_day_of_month?' do

      it 'true if timing == :day_of_month' do
        condition.timing = ConditionResponder::TIMING_DAY_OF_MONTH
        expect(ConditionResponder.timing_is_day_of_month?(timing)).to be true
      end

      it 'false otherwise' do
        condition.timing = ConditionResponder::DEFAULT_TIMING
        expect(ConditionResponder.timing_is_day_of_month?(timing)).to be false
      end
    end

  end

  describe '.timing_matches_today?' do

    let(:condition) { build(:condition) }
    let(:timing) { ConditionResponder.get_timing(condition) }

    it 'true if timing is every day' do
      config = {}
      expect(ConditionResponder.timing_matches_today?(ConditionResponder::TIMING_EVERY_DAY, config)).to be true
    end

    it 'true if today is timing day of month? ' do
      condition.timing = ConditionResponder::TIMING_DAY_OF_MONTH
      config = {on_month_day: Date.current.day}
      expect(ConditionResponder.timing_matches_today?(ConditionResponder::TIMING_EVERY_DAY, config)).to be true
    end

    it 'false otherwise' do
      condition.timing = ConditionResponder::DEFAULT_TIMING
      expect(ConditionResponder.timing_matches_today?(timing, config)).to be false
    end
  end


  describe '.today_is_timing_day_of_month?' do

    let(:condition) { build(:condition) }
    let(:timing) { ConditionResponder.get_timing(condition) }

    it "true if timing is day of month AND config[:on_month_day] is today's day of the month" do
      condition.timing = ConditionResponder::TIMING_DAY_OF_MONTH
      config = {on_month_day: Date.current.day}
      expect(ConditionResponder.today_is_timing_day_of_month?(timing, config)).to be true
    end

    it 'false if :on_month_day is not in config' do
      condition.timing = ConditionResponder::TIMING_DAY_OF_MONTH
      config = {}
      expect(ConditionResponder.today_is_timing_day_of_month?(timing, config)).to be false
    end

    it "false if on_month_day is not today's date" do
      condition.timing = ConditionResponder::TIMING_DAY_OF_MONTH
      config = {on_month_day: Date.current.day - 1}
      expect(ConditionResponder.today_is_timing_day_of_month?(timing, config)).to be false
    end

  end


  describe '.confirm_correct_timing' do

    let(:condition) { build(:condition, :every_day) }
    let(:timing) { ConditionResponder.get_timing(condition) }

    it 'does not raise exception if received timing == expected' do
      expect { ConditionResponder.confirm_correct_timing(:every_day, timing, log) }
        .not_to raise_error
    end

    it 'raises exception if received timing != expected' do
      expect { ConditionResponder.confirm_correct_timing(:not_every_day, :every_day, log) }
        .to raise_exception ArgumentError,
                            'Received timing: not_every_day but expected: every_day'
    end

  end

end
