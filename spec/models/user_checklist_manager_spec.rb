require 'rails_helper'

require 'shared_context/users'

RSpec.describe UserChecklistManager do

  include ActiveSupport::Testing::TimeHelpers

  include_context 'create users'

  let(:june_6) { Time.zone.local(2020, 6, 6) }
  let(:june_5) { Time.zone.local(2020, 6, 5) }

  # TODO get this from AppConfiguration later / stub (the membership guidelines list type, etc.)
  let(:membership_guidelines_type_name) { AdminOnly::MasterChecklistType::MEMBER_GUIDELINES_LIST_TYPE }
  let(:guideline_list_type) { create(:master_checklist_type, name: membership_guidelines_type_name) }
  let(:guideline_master) { create(:master_checklist, master_checklist_type: guideline_list_type) }



  describe '.first_incomplete_membership_guideline_section_for' do

    it 'nil if all are completed' do
      user_all_completed =  build(:user, first_name: 'AllCompleted')
      user_checklist = create(:user_checklist,  user: user_all_completed,
                              master_checklist: guideline_master,
                              num_completed_children: 2)
      allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                  .with(user_all_completed)
                                                  .and_return(user_checklist)
      expect(described_class.first_incomplete_membership_guideline_section_for(user_all_completed)).to be_nil
    end

    it 'first completed guideline (based on the list position) of the membership guidelines' do
      user_some_completed =  build(:user, first_name: 'SomeCompleted')
      user_checklist = create(:user_checklist,  user: user_some_completed,
                              master_checklist: guideline_master,
                              num_children: 3,
                              num_completed_children: 2)
      allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                  .with(user_some_completed)
                                                  .and_return(user_checklist)
      allow(described_class).to receive(:membership_guidelines_list_for)
                                  .with(user_some_completed)
                                  .and_return(user_checklist)
      result = described_class.first_incomplete_membership_guideline_section_for(user_some_completed)
      expect(result.completed?).to be_falsey
    end
  end


  describe '.completed_membership_guidelines_checklist?' do

    it 'returns false if there are no lists for the user' do
      allow(AdminOnly::MasterChecklist).to receive(:latest_membership_guideline_master)
                                             .and_return(create(:membership_guidelines_master_checklist))
      expect(described_class.completed_membership_guidelines_checklist?(create(:user))).to be_falsey
    end

    it 'calls UserChecklist .all_completed? to determine if it is complete or not' do
      checklist = create(:user_checklist)
      user_for_checklist = checklist.user

      allow(UserChecklist).to receive(:membership_guidelines_for_user).and_return([checklist])
      expect(checklist).to receive(:all_completed?)

      described_class.completed_membership_guidelines_checklist?(user_for_checklist)
    end
  end


  describe '.membership_guidelines_list_for' do

    it 'returns nil if there are no lists for the user' do
      expect(described_class.membership_guidelines_list_for(create(:user))).to be_nil
    end

    it 'returns the most recently created user checklist' do
      user = create(:user, first_name: 'User', last_name: 'With-Checklists')

      # make 2 and expect the most recently created one to be returned
      travel_to(Time.now - 2.days) do
        create(:user_checklist, user: user, name: 'older list')
      end

      create(:user_checklist, user: user, name: 'more recent list')

      allow(UserChecklist).to receive(:membership_guidelines_for_user).and_return(user.checklists)

      expect(described_class.membership_guidelines_list_for(user)).to eq UserChecklist.find_by(name: 'more recent list')
    end

  end


  describe '.completed_guidelines_for' do

    it 'empty list if  there is no list for the user' do
      user_no_checklist = build(:user)
      expect(described_class.completed_guidelines_for(user_no_checklist)).to be_empty
    end

    context 'no guidelines completed' do
      it 'empty list' do
        num_completed = 0
        user_none_completed = build(:user)
        user_checklist = create(:user_checklist,  user: user_none_completed,
                                master_checklist: guideline_master,
                                num_children: 2,
                                num_completed_children: num_completed)
        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                     .with(user_none_completed)
                                                     .and_return(user_checklist)

        expect(described_class.completed_guidelines_for(user_none_completed)).to be_empty
      end
    end

    context 'some guidelines completed' do
      it 'list with only the completed guidelines' do
        num_completed = 1
        user_some_completed = build(:user, first_name: 'SomeCompleted')
        user_checklist = create(:user_checklist, user: user_some_completed,
               master_checklist: guideline_master,
               num_children: 3,
               num_completed_children: num_completed)
        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_some_completed)
                                                    .and_return(user_checklist)
        expect(described_class.completed_guidelines_for(user_some_completed).count).to eq num_completed
      end
    end

    context 'all guidelines completed' do
      it 'list all the guidelines' do
        num_completed = 2
        user_all_completed =  build(:user, first_name: 'AllCompleted')
        user_checklist = create(:user_checklist, :completed,
                                user: user_all_completed,
                                master_checklist: guideline_master,
                                num_completed_children: num_completed)
        expect(user_checklist.all_completed?).to be_truthy

        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_all_completed)
                                                    .and_return(user_checklist)
        expect(described_class.completed_guidelines_for(user_all_completed).count).to eq num_completed
      end
    end
  end


  describe '.not_completed_guidelines_for' do

    it 'empty list if  there is no list for the user' do
      user_no_checklist = build(:user)
      expect(described_class.not_completed_guidelines_for(user_no_checklist)).to be_empty
    end

    context 'no guidelines completed' do
      it 'all of the guidelines' do
        num_children = 2
        num_completed = 0
        user_none_completed = build(:user)
        user_checklist = create(:user_checklist, user: user_none_completed,
                                master_checklist: guideline_master,
                                num_children: num_children,
                                num_completed_children: num_completed)
        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_none_completed)
                                                    .and_return(user_checklist)
        expect(described_class.not_completed_guidelines_for(user_none_completed).count).to eq num_children
      end
    end

    context 'some guidelines completed' do
      it 'list with only the uncompleted guidelines' do
        num_completed = 1
        num_children = 3
        expected_uncompleted = num_children - num_completed
        user_some_completed = build(:user, first_name: 'SomeCompleted')
        user_checklist = create(:user_checklist, user: user_some_completed,
                                master_checklist: guideline_master,
                                num_children: num_children,
                                num_completed_children: num_completed)

        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_some_completed)
                                                    .and_return(user_checklist)
        allow(described_class).to receive(:membership_guidelines_list_for)
                                    .with(user_some_completed)
                                    .and_return(user_checklist)

        expect(user_checklist.all_that_are_completed.count).to eq 1
        expect(user_checklist.all_that_are_uncompleted.count).to eq 3

        expect(described_class.not_completed_guidelines_for(user_some_completed).count).to eq(expected_uncompleted)
      end
    end

    context 'all guidelines are completed' do
      it 'is empty' do
        num_completed = 2
        user_all_completed =  build(:user, first_name: 'AllCompleted')
        user_checklist = create(:user_checklist, :completed,
                                user: user_all_completed,
                                master_checklist: guideline_master,
                                num_completed_children: num_completed)
        expect(user_checklist.all_completed?).to be_truthy

        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_all_completed)
                                                    .and_return(user_checklist)
        expect(described_class.not_completed_guidelines_for(user_all_completed).count).to eq 0
      end
    end
  end

end
