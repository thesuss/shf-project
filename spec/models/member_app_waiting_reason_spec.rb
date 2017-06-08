require 'rails_helper'

RSpec.describe AdminOnly::MemberAppWaitingReason, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:member_app_waiting_reason)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name_sv }
    it { is_expected.to have_db_column :description_sv }
    it { is_expected.to have_db_column :name_en }
    it { is_expected.to have_db_column :description_en }
    it { is_expected.to have_db_column :is_custom }
  end


  describe 'Validations' do

    it { is_expected.to validate_presence_of :name_sv }

  end

  describe '#other_reason_placeholder?' do

    let(:reason) { subject }

    it 'false if name_sv is empty' do
      reason.name_sv = ''
      expect(reason.other_reason_placeholder?).to be_falsey
    end

    it 'false if name_sv is nil' do
      reason.name_sv = nil
      expect(reason.other_reason_placeholder?).to be_falsey
    end

    it "false if name_sv is not the 'other reason' name" do
      reason.name_sv = "blorf"
      expect(reason.other_reason_placeholder?).to be_falsey
    end

    it "true if name_sv is equal to the 'other reason' name" do
      reason.name_sv = reason.class.other_reason_name
      expect(reason.other_reason_placeholder?).to be_truthy
    end

  end

end
