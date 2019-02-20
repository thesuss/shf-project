require 'rails_helper'


RSpec.describe SchemaDotOrg::PostalAddress, type: :model do

  let(:item) {
    addr                     = described_class.new
    addr.streetAddress       = 'street address'
    addr.postOfficeBoxNumber = '3a'
    addr.postalCode          = '01010101 01'
    addr.addressRegion       = 'Blorfish'
    addr.addressLocality     = 'Blorf county'
    addr.addressCountry      = 'Blorfland'
    addr
  }


  it '_to_json_struct' do
    expect(item._to_json_struct).to eq({
                                           "streetAddress"       => 'street address',
                                           "postOfficeBoxNumber" => '3a',
                                           "postalCode"          => '01010101 01',
                                           "addressRegion"       => 'Blorfish',
                                           "addressLocality"     => 'Blorf county',
                                           "addressCountry"      => 'Blorfland'
                                       })
  end

end
