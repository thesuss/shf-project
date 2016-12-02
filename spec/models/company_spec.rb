require 'rails_helper'

RSpec.describe Company, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:company)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :company_number }
    it { is_expected.to have_db_column :phone_number }
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :street }
    it { is_expected.to have_db_column :post_code }
    it { is_expected.to have_db_column :city }
    it { is_expected.to have_db_column :region }
    it { is_expected.to have_db_column :website }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :company_number }

    it { is_expected.to validate_length_of(:company_number).is_equal_to(10) }

    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('userexample.com').for(:email) }

  end

  describe 'Associations' do
    it { is_expected.to have_and_belong_to_many :business_categories }
  end

  describe 'categories = all employee categories' do

    it '3 employees, each with 1 unique category' do

      employee1 = create(:user, email: 'emp1@happymutts.com')
      employee2 = create(:user, email: 'emp2@happymutts.com')
      employee3 = create(:user, email: 'emp3@happymutts.com')

      create(:membership_application, user: employee1, num_categories: 1, category_name: 'cat1', company_number: '5562252998')
      create(:membership_application, user: employee2, num_categories: 1, category_name: 'cat2', company_number: '5562252998')
      create(:membership_application, user: employee3, num_categories: 1, category_name: 'cat3', company_number: '5562252998')

      company = create(:company, company_number: '5562252998')

      expect(company.categories.count).to eq 3
      expect(company.categories.map { |c| c[:name] }).to contain_exactly('cat1', 'cat2', 'cat3')

    end


    def has_single_category(category_holder, category)
      category_holder.business_categories.delete_all
      category_holder.business_categories << category
      category_holder
    end


    it '3 employees, each with the same category' do

      company = create(:company, company_number: '5562252998')

      employee1 = create(:user, email: 'emp1@happymutts.com')
      employee2 = create(:user, email: 'emp2@happymutts.com')
      employee3 = create(:user, email: 'emp3@happymutts.com')

      category = create(:business_category)
      app1 = create(:membership_application, user: employee1, company_number: '5562252998')
      app2 = create(:membership_application, user: employee2, company_number: '5562252998')
      app3 = create(:membership_application, user: employee3, company_number: '5562252998')

      has_single_category(app1, category)
      has_single_category(app2, category)
      has_single_category(app3, category)

      expect(company.categories.count).to eq 1
      expect(company.categories.map { |c| c[:name] }).to contain_exactly('BusinessCategoryName')

    end


  end
end
