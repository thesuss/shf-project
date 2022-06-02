require 'rails_helper'

RSpec.describe CompanyMembership, type: :model do
  let(:company_1) { create(:company, name: 'Company 1') }
  let(:company_2) { create(:company, name: 'Company 2') }

  let(:aug30_2020) { Date.new(2020, 8, 30) }
  let(:sept1_2020) { Date.new(2020, 9, 1) }
  let(:sept2_2020) { Date.new(2020, 9, 2) }
  let(:aug30_2021) { Date.new(2021, 8, 30) }
  let(:sept1_2021) { Date.new(2021, 9, 1) }
  let(:sept2_2021) { Date.new(2021, 9, 1) }
  let(:aug30_2022) { Date.new(2022, 8, 30) }
  let(:sept1_2022) { Date.new(2022, 9, 1) }
  let(:sept2_2022) { Date.new(2022, 9, 1) }
  let(:aug30_2023) { Date.new(2023, 8, 30) }
  let(:sept1_2023) { Date.new(2023, 9, 1) }
  let(:aug30_2024) { Date.new(2024, 8, 30) }

  let(:co1_membership_202109) { create(:company_membership, owner: company_1,
                                       member_number: 'co1_membership_202109',
                                       first_day: sept1_2021,
                                       last_day: aug30_2022) }
  let(:co1_membership_202209) { create(:company_membership, owner: company_1,
                                       member_number: 'co1_membership_202209',
                                       first_day: sept1_2022,
                                       last_day: aug30_2023) }
  let(:co2_membership_202009) { create(:company_membership, owner: company_2,
                                       member_number: 'co2_membership_202009',
                                       first_day: sept1_2020,
                                       last_day: aug30_2021) }
  let(:co2_membership_202109) { create(:company_membership, owner: company_2,
                                       member_number: 'co2_membership_202109',
                                       first_day: sept1_2021,
                                       last_day: aug30_2022) }

  def make_all_memberships
    [co1_membership_202109, co1_membership_202209,
     co2_membership_202009, co2_membership_202109]
  end

  describe '.covering_date' do
    it 'where first_day <= the given date and last_day >= the given date' do
      make_all_memberships
      expect(described_class.covering_date(sept1_2021).to_a).to match_array([co1_membership_202109,
                                                                             co2_membership_202109])
    end

    it 'default date is Date.current' do
      make_all_memberships
      travel_to(sept2_2021) do
        expect(described_class.covering_date.to_a).to match_array([co1_membership_202109,
                                                                   co2_membership_202109])
      end
    end

    it 'sorted by :last_day (asc) then :id (asc), oldest last_day is first' do
      make_all_memberships
      co1_membership_202109_2yrs_long = create(:company_membership, owner: company_1,
                                               member_number: 'co1_membership_202109_2yrs_long',
                                               first_day: sept1_2021,
                                               last_day: aug30_2023)
      co1_membership_202209_2yrs_long = create(:company_membership, owner: company_1,
                                               member_number: 'co1_membership_202209_2yrs_long',
                                               first_day: sept1_2022,
                                               last_day: aug30_2024)
      travel_to(sept2_2022) do
        expect(described_class.covering_date.to_a).to eq([co1_membership_202209,
                                                          co1_membership_202109_2yrs_long,
                                                          co1_membership_202209_2yrs_long])
      end
    end
  end

  describe '.for_owner_covering_date' do
    it 'where owner is the given owner' do
      make_all_memberships
      expect(described_class.for_owner_covering_date(company_2, sept1_2021).to_a).to match_array([co2_membership_202109])
    end

    it 'calls .covering_date with the given date' do
      expect(described_class).to receive(:covering_date).with(sept2_2021)
      described_class.for_owner_covering_date(company_1, sept2_2021)
    end
  end

  describe '.starting_on_or_after' do

    it 'default given date to use as the starting date is Date.current' do
      expect(described_class).to receive(:where).with('first_day >= ?', Date.current)
      described_class.starting_on_or_after
    end

    it 'empty if none have first day >= the given date' do
      expect(described_class.starting_on_or_after).to be_empty
    end

    it 'all that have first_day on or after the given date' do
      make_all_memberships
      expect(described_class.starting_on_or_after(sept1_2021).to_a).to match_array([co1_membership_202109,
                                                                                    co1_membership_202209,
                                                                                    co2_membership_202109])
    end
  end

  describe '.for_owner_starting_on_or_after' do

    it 'only returns memberships for the owner' do
      make_all_memberships
      expect(described_class.for_owner_starting_on_or_after(company_1).map(&:owner).include?(company_2)).to be_falsey
    end

    it 'default first_day is Date.current' do
      expect(described_class).to receive(:starting_on_or_after).with(Date.current)
      described_class.for_owner_starting_on_or_after(company_1)
    end

    it 'only returns memberships with the first day on or after the first_day' do
      make_all_memberships
      expect(described_class.for_owner_starting_on_or_after(company_1, sept1_2021).map(&:first_day))
        .to match_array([sept1_2021, sept1_2022])
    end
  end

  describe '.first_day_from_last' do
    it '= last_day - term_length + 1' do
      expect(described_class).to receive(:term_length).and_return(10.days)
      expect(described_class.first_day_from_last(Date.current)).to eq(Date.current - 10.days + 1.day)
    end
  end

  describe '.last_day_from_first' do
    it '= first_day + term_length - 1' do
      expect(described_class).to receive(:term_length).and_return(10.days)
      expect(described_class.last_day_from_first(Date.current)).to eq(Date.current + 10.days - 1.day)
    end
  end

  describe 'other_day_from' do
    before(:each) { expect(described_class).to receive(:term_length).at_least(1).time.and_return(10.days) }

    it 'date + (given multiplier *(term_length - 1.day))' do
      expect(described_class.other_day_from(Date.current, 1)).to eq(Date.current + 10 - 1.day)
      expect(described_class.other_day_from(Date.current, -1)).to eq(Date.current - 10 + 1.day)
    end

    it 'default multipler is +1' do
      expect(described_class.other_day_from(Date.current)).to eq(Date.current + 10 - 1.day)
    end

  end

  describe 'set_first_day_and_last' do

    it 'default first day is Date.current' do
      expect(subject.first_day).to be_nil
      subject.set_first_day_and_last
      expect(subject.first_day).to eq(Date.current)
    end

    context 'last day is not given' do
      it 'calculates the last day based on the first day given' do
        allow(described_class).to receive(:term_length).and_return(5.days)
        expect(subject.last_day).to be_nil
        first_day = Date.current + 1
        subject.set_first_day_and_last(first_day: first_day)
        expect(subject.last_day).to eq(first_day - 1 + 5.days)
      end
    end

    it 'updates (persists) the first_day and last_day' do
      expect(subject.first_day).to be_nil
      expect(subject.last_day).to be_nil
      first_day = Date.current + 1
      last_day = Date.current + 100
      subject.set_first_day_and_last(first_day: first_day, last_day: last_day)
      expect(subject.first_day).to eq(first_day)
      expect(subject.last_day).to eq(last_day)
    end
  end

  describe 'first_membership?' do

    it 'calls any_membership_within with the given time period' do
      given_time_period = -1.month
      expect(co1_membership_202209).to receive(:any_membership_within)
                                         .with(given_time_period).and_return([])
      co1_membership_202209.first_membership?(time_period: given_time_period)
    end

    it 'default time period is the time limit for the definition of a first membership' do
      expect(co1_membership_202209).to receive(:any_membership_within)
                                         .with(Membership.first_membership_time_period).and_return([])
      co1_membership_202209.first_membership?
    end

    it 'true if no other memberships for this owner' do
      expect(co1_membership_202109.first_membership?(time_period: (Date.current - sept1_2021))).to be_truthy
    end

    context 'at least one other memberships for this owner' do
      before(:each) { make_all_memberships }

      it 'false if there is one within the given time frame' do
        expect(co1_membership_202109.first_membership?(time_period: (Date.current - sept1_2021))).to be_falsey
      end

      it 'true if there is not one within the given time frame' do
        expect(co1_membership_202109.first_membership?(time_period: -10.years)).to be_truthy
      end
    end
  end

  describe 'any_membership_within' do
    let(:start_date) { sept1_2022 }
    let(:given_time_period) { 1.year }

    it 'calls the class method (scope) to get all memberships for this owner, starting on or after starting date - time_period' do
      expect(described_class).to receive(:for_owner_starting_on_or_after)
                                   .with(co1_membership_202209.owner, start_date - given_time_period)
      co1_membership_202209.any_membership_within(given_time_period, starting_date: start_date)
    end

    it 'default time period is the time limit for the definition of a first membership' do
      expect(described_class).to receive(:for_owner_starting_on_or_after)
                                   .with(co1_membership_202209.owner, start_date - Membership.first_membership_time_period)
      co1_membership_202209.any_membership_within(starting_date: start_date)
    end

    it 'default starting date is Date.current' do
      expect(described_class).to receive(:for_owner_starting_on_or_after)
                                   .with(co1_membership_202209.owner, Date.current - given_time_period)
      co1_membership_202209.any_membership_within(given_time_period)
    end
  end
end
