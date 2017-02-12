require 'rails_helper'

RSpec.describe Company, type: :model do

  let(:no_name) { c = create(:company, name: '', company_number: '2120000142')
  c.old_region = 'Sveriges'
  c
  }
  let(:nil_region) { c = create(:company, name: 'Nil Region', company_number: '6112107039')
  c.region = nil
  c.old_region = 'Sveriges'
  c.save
  c
  }
  let(:nil_old_region) { c = create(:company, name: 'Nil Old Region', company_number: '5569467466')
  c.old_region = nil
  c.save
  c
  }
  let(:empty_str_old_region) { c = create(:company, name: 'Empty Str Old Region', company_number: '3609340140')
  c.old_region = ''
  c.save
  c
  }

  let(:nil_regions) { c = create(:company, name: 'Nil Region and Nil Old Region', company_number: '5906055081')
  c.region = nil
  c.old_region = nil
  c.save
  c
  }

  let(:nil_region_blank_old_region) { c = create(:company, name: 'Nil Region and Empty Str Old Region', company_number: '5560360793')
  c.region = nil
  c.old_region = ''
  c.save
  c
  }

  let(:complete_co) { create(:company, name: 'Complete Company', company_number: '4268582063') }


  let!(:complete_companies) {
    complete_cos = []
    complete_cos << complete_co
    complete_cos << nil_region
    complete_cos << nil_old_region
    complete_cos << empty_str_old_region
    complete_cos
  }

  let!(:incomplete_companies) {
    incomplete_cos = []
    incomplete_cos << no_name
    incomplete_cos << nil_regions
    incomplete_cos << nil_region_blank_old_region
    incomplete_cos
  }


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
    it { is_expected.to have_db_column :region_id }
    it { is_expected.to have_db_column :old_region }
    it { is_expected.to have_db_column :website }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :company_number }

    it { is_expected.to validate_length_of(:company_number).is_equal_to(10) }

    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('userexample.com').for(:email) }

  end

  describe 'Associations' do
    it { is_expected.to have_many(:business_categories).through(:membership_applications) }
    it { is_expected.to have_many(:membership_applications) }
    it { is_expected.to belong_to(:region) }
  end


  describe 'complete scope' do

    it 'only returns companies that are complete' do

      complete_scope = Company.complete
      expect(complete_scope).to match_array(complete_companies)
    end

    it 'does not return any incomplete companies' do
      complete_scope = Company.complete
      expect(complete_scope & incomplete_companies).to match_array([])
    end

  end


  describe 'categories = all employee categories' do

    let(:company) { create(:company, company_number: '5562252998') }

    let(:employee1) { create(:user) }
    let(:employee2) { create(:user) }
    let(:employee3) { create(:user) }

    let(:cat1) { create(:business_category, name: 'cat1') }
    let(:cat2) { create(:business_category, name: 'cat2') }
    let(:cat3) { create(:business_category, name: 'cat3') }

    let(:m1) do
      create(:membership_application, :accepted, user: employee1,
             num_categories: 0,
             company_number: company.company_number)
    end
    let(:m2) do
      create(:membership_application, :accepted, user: employee2,
             num_categories: 0,
             company_number: company.company_number)
    end
    let(:m3) do
      create(:membership_application, :accepted, user: employee3,
             num_categories: 0,
             company_number: company.company_number)
    end

    before(:all) do
      Company.delete_all
      MembershipApplication.delete_all
      User.delete_all
    end

    it '3 employees, each with 1 unique category' do
      m1.business_categories << cat1
      m2.business_categories << cat2
      m3.business_categories << cat3

      expect(company.business_categories.count).to eq 3
      expect(company.business_categories.map(&:name))
          .to contain_exactly('cat1', 'cat2', 'cat3')
    end

    it '3 employees, each with the same category' do
      m1.business_categories << cat1
      m2.business_categories << cat1
      m3.business_categories << cat1

      expect(company.business_categories.distinct.count).to eq 1
      expect(company.business_categories.count).to eq 3
      expect(company.business_categories.distinct.map(&:name))
          .to contain_exactly('cat1')
    end
  end


  describe '#complete?' do

    it 'no name == not complete' do
      expect(no_name.complete?).to be_falsey
    end

    it 'nil region, but has old region == complete' do
      expect(nil_region.complete?).to be_truthy
    end

    it 'nil old region, but has region == complete' do
      expect(nil_old_region.complete?).to be_truthy
    end

    it 'old region=' ', but has region == complete' do
      expect(empty_str_old_region.complete?).to be_truthy
    end

    it 'nil region and nil old_region == not complete' do
      expect(nil_regions.complete?).to be_falsey
    end

    it 'nil region and old_region=' ' == not complete' do
      expect(nil_region_blank_old_region.complete?).to be_falsey
    end


    it 'select complete? returns only the complete ones' do

      complete_using_method = Company.all.select(&:complete?)

      expect(complete_using_method).to match_array(complete_companies)

    end

    it 'reject complete? returns only the incomplete ones' do

      incomplete_using_method = Company.all.reject(&:complete?)

      expect(incomplete_using_method).to match_array(incomplete_companies)

    end


  end

end
