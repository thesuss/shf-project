require 'rails_helper'

RSpec.describe MemberPage, type: :model do
  let(:member_page) { create(:member_page) }

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:member_page)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :filename }
    it { is_expected.to have_db_column :title }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :filename }
  end

  describe '.title' do
    it 'creates a new record if non-existant' do
      expect { MemberPage.title('page_name') }.to change(MemberPage, :count).by(1)
    end

    it 'returns capitalized file name as default title' do
      expect(MemberPage.title('page_name')).to eq 'Page_name'
    end

    it 'returns title if present' do
      expect(MemberPage.title(member_page.filename)).to eq member_page.title
    end
  end
end
