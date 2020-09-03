require 'rails_helper'

RSpec.describe AdminOnly::MasterChecklistType, type: :model do

  describe 'Factories' do
    it ':membership_guidelines_master_checklist_type' do
      expect(AdminOnly::MasterChecklistType.membership_guidelines_type).to be_nil
      master_type = create(:membership_guidelines_master_checklist_type)
      expect(AdminOnly::MasterChecklistType.membership_guidelines_type).to eq master_type
    end
  end
end
