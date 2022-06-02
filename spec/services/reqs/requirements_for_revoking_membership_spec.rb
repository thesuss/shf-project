require 'rails_helper'

module Reqs
  RSpec.describe RequirementsForRevokingMembership do
    let(:subject) { RequirementsForRevokingMembership }

    describe '.requirements_met?' do
      let(:yesterday) { Date.current - 1.day }

      context 'user.member? is true' do
        let(:member) { build(:user) }
        before(:each) { allow(member).to receive(:member?).and_return(true) }

        it 'false if member is in good standing (cannot revoke if the member is in good standing)' do
          allow(member).to receive(:member_in_good_standing?).and_return(true)

          expect(subject.requirements_met?({ entity: member })).to be_falsey
        end

        it 'true if not a member in good standing (should revoke if not in good standing)' do
          allow(member).to receive(:member_in_good_standing?).and_return(false)

          expect(subject.requirements_met?({ entity: member })).to be_truthy
        end
      end

      it 'false if entity.member? == false (must be a member in order to revoke membership)' do
        not_a_member = build(:user)
        allow(not_a_member).to receive(:member?).and_return(false)
        expect(subject.requirements_met?({ entity: not_a_member })).to be_falsey
      end
    end
  end
end
