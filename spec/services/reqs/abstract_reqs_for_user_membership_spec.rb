require 'rails_helper'
require 'shared_context/named_dates'

module Reqs
  RSpec.describe AbstractReqsForUserMembership do
    include_context 'named dates'

    before(:each) do
      # stub this so we don't have to create the MasterChecklist for the Member Guidelines checklist
      # if a ShfApplication is accepted.
      allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for).and_return(true)
    end

    let(:subject) { AbstractReqsForUserMembership }
    let(:user) { build(:user) }


    describe '.membership_guidelines_checklist_done?' do
      it 'asks the user if membership_guidelines_checklist_done?' do
        expect(user).to receive(:membership_guidelines_checklist_done?)
        subject.membership_guidelines_checklist_done?(user)
      end
    end
  end
end
