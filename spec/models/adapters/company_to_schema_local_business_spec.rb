require 'rails_helper'

RSpec.describe Adapters::CompanyToSchemaLocalBusiness do

  let(:cat1_double) { instance_double(BusinessCategory, name: 'cat1') }
  let(:cat2_double) { instance_double(BusinessCategory, name: 'cat2') }

  let(:addr1_double) { instance_double(Address) }
  let(:addr2_double) { instance_double(Address) }
  let(:co_double) do
    instance_double(Company, { name: 'Co name', description: 'Co description',
                               id: '101',
                               email: 'Co email',
                               phone_number: 'Co 12345',
                               business_categories: [cat1_double, cat2_double],
                               main_address: addr1_double,
                               addresses: [addr1_double, addr2_double]
    })
  end
  let(:dot_org_address_double) { instance_double(SchemaDotOrg::PostalAddress) }
  let(:given_url) { 'this/is/the/given/url'}

  let(:subject) { Adapters::CompanyToSchemaLocalBusiness.new(co_double, url: given_url) }


  it 'target_class' do
    expect(subject.target_class).to eq SchemaDotOrg::LocalBusiness
  end


  describe 'set_target_attributes' do

    let(:new_target_schema) { SchemaDotOrg::LocalBusiness.new  }
    before(:each) do
      allow(Adapters::AddressesIntoSchemaLocalBusiness).to receive(:set_address_properties)
                                                   .and_return(new_target_schema)
    end

    simple_attribs_assigned = [:name, :description, :email]
    simple_attribs_assigned.each do |attrib|
      it "target.#{attrib} = adaptee.#{attrib}" do
        expect(new_target_schema).to receive("#{attrib}=".to_sym)
        expect(co_double).to receive(attrib)
        subject.set_target_attributes(new_target_schema)
      end
    end

    it 'target.url = url given when subject initialized' do
      expect(new_target_schema).to receive(:url=).with(given_url)
      subject.set_target_attributes(new_target_schema)
    end

    it 'target.telephone = adaptee.phone_number' do
      expect(new_target_schema).to receive(:telephone=)
      expect(co_double).to receive(:phone_number)
      subject.set_target_attributes(new_target_schema)
    end

    it 'image is the full SHF url plus the company H-markt path' do
      result = subject.set_target_attributes(new_target_schema)
      expect(result.image).to match(/#{I18n.t('shf_medlemssystem_url')}\/hundforetag\/101\/company_h_brand/)
    end

    it 'addresses are created with the AddressesIntoSchemaLocalBusiness adapter' do
      expect(Adapters::AddressesIntoSchemaLocalBusiness).to receive(:set_address_properties)
                                                    .with(co_double.addresses,
                                                          co_double.main_address,
                                                          new_target_schema )
      subject.set_target_attributes(new_target_schema)
    end

    it 'knowsLanguage is hardcoded to sv-SE' do
      expect(new_target_schema).to receive(:knowsLanguage=).with('sv-SE')
      subject.set_target_attributes(new_target_schema)
    end

    describe 'knowsAbout' do

      it 'is nil if there are no business categories' do
        allow(co_double).to receive(:business_categories).and_return([])
        result = subject.set_target_attributes(new_target_schema)
        expect(result.knowsAbout).to be_nil
      end

      it 'array of the business category names with I18n.t("dog").capitalize preprended' do
        result = subject.set_target_attributes(new_target_schema)
        expect(result.knowsAbout).to match_array(['Hund cat1', 'Hund cat2'])
      end
    end
  end
end
