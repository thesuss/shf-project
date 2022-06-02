# frozen_string_literal: true

require 'rails_helper'

module Reqs
  RSpec.describe RenewalWithFailInfo do

    class TestingClass
      include RenewalWithFailInfo

      @failed_requirements = []
    end


    let(:described_class) { TestingClass }

    let(:user) { build(:user) }
    let(:faux_membership) do
      faux_m = build(:membership, owner: user)
      allow(faux_m).to receive(:id).and_return(42)
      faux_m
    end

    describe '.current_membership_short_str' do
      it 'calls .short_membership_str with the current membership for the given user' do
        allow(user).to receive(:current_membership).and_return(faux_membership)
        expect(described_class).to receive(:short_membership_str).with(faux_membership)
        described_class.current_membership_short_str(user)
      end
    end

    describe '.most_recent_membership_short_str' do
      it 'calls .short_membership_str with the current membership for the given user' do
        allow(user).to receive(:current_membership).and_return(nil)
        allow(user).to receive(:most_recent_membership).and_return(faux_membership)
        expect(described_class).to receive(:short_membership_str).with(faux_membership)
        described_class.most_recent_membership_short_str(user)
      end
    end

    describe '.short_membership_str' do
      it "is 'nil' if the membership is nil" do
        expect(described_class.short_membership_str(nil)).to eq('nil')
      end

      it "is 'membership_id: first_day - last_day'" do
        first_day = faux_membership.first_day.strftime('%Y-%m-%d')
        last_day = faux_membership.last_day.strftime('%Y-%m-%d')
        expect(described_class.short_membership_str(faux_membership)).to match(/\[(\d)+\] #{first_day} - #{last_day}/)
      end
    end

    describe '.record_requirement_failure' do
      let(:given_date) { Date.current }

      it 'calls the method on the object with the method arguments e.g. obj.method(method_args)' do
        expect(user).to receive(:valid_date_for_renewal?)
                          .with(given_date)
                          .and_return(true)
        described_class.record_requirement_failure(user, :valid_date_for_renewal?, given_date, 'string describing the failure')
      end

      context 'result is falsey' do
        before(:each) do
          allow(user).to receive(:valid_date_for_renewal?)
                           .with(given_date)
                           .and_return(false)
        end

        it 'records the failure' do
          expect(described_class).to receive(:record_failure)
                                       .with(:valid_date_for_renewal?, 'string describing the failure', [given_date])
          described_class.record_requirement_failure(user, :valid_date_for_renewal?, given_date, 'string describing the failure')
        end
      end

      it 'returns the result from calling the method' do
        allow(described_class).to receive(:record_failure)

        allow(user).to receive(:valid_date_for_renewal?)
                         .with(given_date)
                         .and_return(true)
        expect(described_class.record_requirement_failure(user, :valid_date_for_renewal?, given_date, 'string describing the failure')).to be_truthy

        allow(user).to receive(:valid_date_for_renewal?)
                         .with(given_date)
                         .and_return(nil)
        expect(described_class.record_requirement_failure(user, :valid_date_for_renewal?, given_date, 'string describing the failure')).to be_nil

        allow(user).to receive(:valid_date_for_renewal?)
                         .with(given_date)
                         .and_return('blorf')
        expect(described_class.record_requirement_failure(user, :valid_date_for_renewal?, given_date, 'string describing the failure')).to eq('blorf')
      end
    end

    describe '.record_failure' do
      it 'appends a Hash of failure info to the list of failed_requirements' do
        described_class.reset_failed_requirements
        described_class.record_failure(:method_name, 'failure string', 1, 2, 3)
        expect(described_class.failed_requirements).to match_array([{ method: :method_name,
                                                                      string: 'failure string',
                                                                      method_args: '[1, 2, 3]' }])
      end
    end

    describe '.failed_requirements' do
      it 'returns the (class) failed requirements' do
        described_class.reset_failed_requirements
        described_class.record_failure(:method_name, 'failure string', 1, 2, 3)
        described_class.record_failure(:method_name, 'failure string2', 12, 22, 32)
        expect(described_class.failed_requirements).to match_array([{ method: :method_name,
                                                                      string: 'failure string',
                                                                      method_args: '[1, 2, 3]' },
                                                                    { method: :method_name,
                                                                      string: 'failure string2',
                                                                      method_args: '[12, 22, 32]' }])
      end
    end

    describe '.reset_failed_requirements' do

      it 'sets failed_requirements to an empty array' do
        described_class.record_failure(:some_method, 'failure string', [1, 2, 3])
        expect(described_class.failed_requirements).not_to be_empty
        described_class.reset_failed_requirements
        expect(described_class.failed_requirements).to be_empty
      end
    end
  end
end
