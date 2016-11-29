require 'rails_helper'

RSpec.describe MembershipApplication, type: :model do
  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:membership_application)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :first_name }
    it { is_expected.to have_db_column :last_name }
    it { is_expected.to have_db_column :company_number }
    it { is_expected.to have_db_column :phone_number }
    it { is_expected.to have_db_column :contact_email }
    it { is_expected.to have_db_column :status }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :contact_email }
    it { is_expected.to validate_presence_of :company_number }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :status }

    it { is_expected.to allow_value('user@example.com').for(:contact_email) }
    it { is_expected.not_to allow_value('userexample.com').for(:contact_email) }

    it { is_expected.to validate_length_of(:company_number).is_equal_to(10) }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_and_belong_to_many :business_categories}
  end
end
