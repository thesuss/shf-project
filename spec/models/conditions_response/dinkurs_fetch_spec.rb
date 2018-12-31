require 'rails_helper'
require 'email_spec/rspec'

require 'shared_context/activity_logger'

RSpec.describe DinkursFetch, type: :model do

  include_context 'create logger'

  let(:condition) { build(:condition, timing: Backup::TIMING_EVERY_DAY) }
  let(:today) { Time.now.strftime '%Y-%m-%d' }

  let(:company_with_dinkurs_id) do
    create(:company, dinkurs_company_id: ENV['DINKURS_COMPANY_TEST_ID'])
  end
  let(:company_without_dinkurs_id) { create(:company) }

  describe '.condition_response' do

    it 'raises exception and writes to log file unless timing is :every_day' do

      condition.timing = :not_every_day

      expect do
        described_class.condition_response(condition, log)
      end.to raise_exception ArgumentError,
                             'Received timing: not_every_day but expected: every_day'

      expect(File.read(filepath))
        .to include 'Received timing: not_every_day but expected: every_day'
    end

    context 'Fetch Dinkurs events', vcr: { cassette_name: 'dinkurs/company_events' } do

      around(:each) do |example|
        Timecop.freeze(Time.zone.local(2018, 6, 1))
        example.run
        Timecop.return
      end

      it 'Fetches events for companies with dinkurs_id' do

        expect{ described_class.condition_response(condition, log) }
          .to change { company_with_dinkurs_id.events.count }.by(3)
      end

      it 'Writes to log file with events count' do
        company_with_dinkurs_id

        described_class.condition_response(condition, log)

        expect(File.read(filepath))
          .to include "Company #{company_with_dinkurs_id.id}: " +
                      "#{company_with_dinkurs_id.events.count} events."
      end

      it 'Does not write to log file for company without dinkurs_id' do
        company_without_dinkurs_id

        described_class.condition_response(condition, log)

        expect(File.read(filepath))
          .not_to include "Company #{company_without_dinkurs_id.id}: "
      end

    end
  end
end
