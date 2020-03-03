require 'rails_helper'


RSpec.describe AdminOnly::UserChecklistFactory do

  let(:simple_user) { create(:user) }


  describe ".create_nested_lists_for_user_from_checklist_masters(list, user)" do

    it 'returns [] if the list is nil' do
      expect(described_class.create_nested_lists_for_user_from_master_checklists(nil, simple_user)).to match_array([])
    end

    it 'returns [] if user is nil' do
      expect(described_class.create_nested_lists_for_user_from_master_checklists([create(:master_checklist)], nil)).to match_array([])
    end

    it 'creates 1 UserChecklist for a MasterChecklist with no children' do
      orig_list = create(:master_checklist, name: 'top item') # have to use create instead of build so that the ancestry gem will generate the ancestry attribute required

      user_checklist = described_class.create_nested_lists_for_user_from_master_checklists([orig_list], simple_user)

      expect(user_checklist.size).to eq 1
      expect(user_checklist.first.user).to eq simple_user
      expect(user_checklist.first.master_checklist).to eq(orig_list)
    end

    it 'creates an ordered list of UserChecklists from a MasterChecklist with children and mirrors the ancestry' do
      list_type = create(:master_checklist_type, name: 'some type')

      item1_top_list_name = 'item1-top_list'
      item1_top_list = AdminOnly::MasterChecklist.create!(master_checklist_type: list_type, name: item1_top_list_name, displayed_text: item1_top_list_name, list_position: 0)

      child1 = AdminOnly::MasterChecklist.create!(master_checklist_type: list_type, name: 'item1-sublist_1', displayed_text: 'item1-sublist_1', parent: item1_top_list, list_position: 10)
      child1.parent = item1_top_list

      item2_top_list_name = 'item2-top_list'
      item2_top_list = AdminOnly::MasterChecklist.create(master_checklist_type: list_type, name: item2_top_list_name, displayed_text: item2_top_list_name, list_position: 2)
      item2_sublist_1 = AdminOnly::MasterChecklist.create(master_checklist_type: list_type, name: 'item2-sublist_1', displayed_text: 'item2-sublist_1', list_position: 21, parent: item2_top_list)
      AdminOnly::MasterChecklist.create(master_checklist_type: list_type, name: 'item2-sublist_1_1', displayed_text: 'item2-sublist_1_1', list_position: 210, parent: item2_sublist_1)

      list_of_items = [item1_top_list, item2_top_list]

      user_checklist = described_class.create_nested_lists_for_user_from_master_checklists(list_of_items, simple_user)

      expect(user_checklist.size).to eq 5
      expect(user_checklist.first.user).to eq simple_user
      expect(user_checklist.map(&:list_position)).to match_array([0, 2, 10, 21, 210])

      arranged = UserChecklist.arrange # This arranges them so that they are nested
      expect((arranged.keys).size).to eq 2 # Once nested, only 2 times are at the top, so the size == 2
      top_checklist_names = arranged.keys.map { |k| k.name }
      expect(top_checklist_names).to match_array([item1_top_list_name, item2_top_list_name])
    end
  end


  describe '.create_membership_checklist_for' do

    it 'raises an error if the membership guidelines template is not found' do
      allow(described_class).to receive(:get_membership_checklist_template).and_return(nil)

      expect { described_class.create_membership_checklist_for(simple_user) }.to raise_error(AdminOnly::UserChecklistTemplateNotFoundError)
    end


    it 'calls create_nested_lists_for_user_from_checklist_masters with the membership guidelines template and the user' do
      member_guidelines = create(:master_checklist, name: 'Become a Member')

      expect(described_class).to receive(:create_nested_lists_for_user_from_master_checklists).with([member_guidelines], simple_user)

      described_class.create_membership_checklist_for(simple_user)
    end
  end


  describe '.create_member_guidelines_checklist_for' do

    it 'raises an error if the membership guidelines template is not found' do
      allow(described_class).to receive(:get_member_guidelines_checklist_template).and_return(nil)

      expect { described_class.create_member_guidelines_checklist_for(simple_user) }.to raise_error(AdminOnly::UserChecklistTemplateNotFoundError)
    end

    it 'calls create_nested_lists_for_user_from_checklist_masters with the membership guidelines template and the user' do
      guidelines_template = create(:master_checklist, name: 'SHF Member Guidelines')
      allow(described_class).to receive(:get_member_guidelines_checklist_template).and_return(guidelines_template)

      expect(described_class).to receive(:create_nested_lists_for_user_from_master_checklists).with([guidelines_template], simple_user)
      described_class.create_member_guidelines_checklist_for(simple_user)
    end
  end


  describe '.get_member_guidelines_checklist_template' do
    it 'calls AdminOnly::MasterChecklist.latest_membership_guideline_master to get it (but will change later)' do
      expect(AdminOnly::MasterChecklist).to receive(:latest_membership_guideline_master)
      described_class.get_member_guidelines_checklist_template
    end
  end


  describe '.get_membership_checklist_template' do

    it 'returns nil if no member checklist is found' do
      expect(described_class.get_membership_checklist_template).to be_nil
    end

    it 'looks for the MasterChecklist with the name "Become a Member"' do
      create(:master_checklist, name: 'Become a Member')
      expect(described_class.get_membership_checklist_template).to be_a AdminOnly::MasterChecklist
    end
  end
end
