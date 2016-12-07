require 'rails_helper'

RSpec.describe CompaniesHelper, type: :helper do

  describe "#company_complete?" do

    it 'returns false if company, name and/or region is nil' do
      company = nil
      expect(helper.company_complete?(company)).to .....

      company = FactoryGirl.create(:company, name: nil)
      expect(helper.company_complete?(company)).to .....

    end
    it 'returns false is company name or region is empty string' do
      company = FactoryGirl.create(:company, name: '')

    end
    it 'returns true if company name and region are non-empty string' do

    end
  end

end
