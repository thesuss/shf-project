require 'rails_helper'

RSpec.describe CompaniesHelper, type: :helper do

  describe '#company_complete?' do
    it 'returns false if company is nil' do
      company = nil
      expect(helper.company_complete?(company)).to eq false
    end
    it 'returns false if company name is nil' do
      company = FactoryGirl.create(:company, name: nil)
      expect(helper.company_complete?(company)).to eq false
    end
    it 'returns false if company region is nil' do
      company = FactoryGirl.create(:company, region: nil)
      expect(helper.company_complete?(company)).to eq false
    end
    it 'returns false is company name or region is empty string' do
      company = FactoryGirl.create(:company, name: '')
      expect(helper.company_complete?(company)).to eq false

    end
    it 'returns true if company name and region are non-empty string' do
      company = FactoryGirl.create(:company)
      expect(helper.company_complete?(company)).to eq true
    end
  end

  describe '#list_companies' do
    it 'returns a companys categories' do
       FactoryGirl.create(:membership_application,
                          company_number: 5562252998,
                          category_name: 'Träning')
      company = FactoryGirl.create(:company,
                                    company_number: 5562252998)
      expect(helper.list_categories(company)).to eq 'Träning'
    end
    it 'returns correct categories' do
      FactoryGirl.create(:membership_application,
                         company_number: 5562252998,
                         category_name: 'Whatever')
      company = FactoryGirl.create(:company,
                                   company_number: 5562252998)
      expect(helper.list_categories(company)).not_to eq 'Träning'
    end
  end
end
