require 'rails_helper'

RSpec.describe Adapter::CompanyToSchemaOrganization do

  let(:test_adapter) {
    co = create(:company)
    co.description = 'description'
    Adapter::CompanyToSchemaOrganization.new(co)
  }


  it 'target_class' do
    expect(test_adapter.target_class).to eq SchemaDotOrg::Organization
  end


  it 'set_target_attributes' do
    schema_org = test_adapter.set_target_attributes(test_adapter.target_class.new)

    expect(schema_org.name).to eq 'SomeCompany'
    expect(schema_org.description).to eq 'description'
    expect(schema_org.email).to eq 'thiscompany@example.com'
    expect(schema_org.url).to eq 'http://www.example.com'
    expect(schema_org.telephone).to eq '123123123'
    expect(schema_org.location.address.streetAddress).to eq 'Hundforetagarevägen 1'
    expect(schema_org.location.address.postalCode).to eq '310 40'
    expect(schema_org.location.address.addressRegion).to eq 'MyString'
    expect(schema_org.location.address.addressLocality).to eq 'Harplinge'
    expect(schema_org.location.address.addressCountry).to eq 'Sverige'
    expect(schema_org.location.geo.latitude).to eq 56.7422437
    expect(schema_org.location.geo.longitude).to eq 12.7206453

  end

end
