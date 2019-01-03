require 'rails_helper'
require 'email_spec/rspec'

require 'shared_context/activity_logger'
require 'shared_context/users'

RSpec.describe MembershipStatusCheck, type: :model do

  include_context 'create logger'
  include_context 'create users'

  let(:condition) { build(:condition, timing: Backup::TIMING_EVERY_DAY) }
  let(:today) { Time.now.strftime '%Y-%m-%d' }


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

    context 'revoke membership if requirements met' do

      before(:each) do
        user
        member_paid_up
        member_expired
      end

      it 'Writes to log file for each revoked membership' do
        described_class.condition_response(condition, log)

        msg = "User #{member_expired.id} (#{member_expired.email}) membership revoked."

        expect(File.read(filepath)).to include msg
      end

      it 'Does not write to log file for non-revoked members' do
        described_class.condition_response(condition, log)

        expect(File.read(filepath)).not_to include "User #{user.id}"
        expect(File.read(filepath)).not_to include "User #{member_paid_up.id}"
      end

    end
  end
end
