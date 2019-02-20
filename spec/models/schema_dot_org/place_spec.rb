require 'rails_helper'


RSpec.describe SchemaDotOrg::Place, type: :model do

  let(:item) {
    place = described_class.new

    address = SchemaDotOrg::PostalAddress.new
    address.streetAddress = 'street address'
    address.addressCountry = 'address country'
    place.address = address

    geo = SchemaDotOrg::GeoCoordinates.new
    geo.latitude = 'latitude'
    geo.longitude = 'longitude'
    place.geo = geo

    place
  }


  it '_to_json_struct' do
    expect(item._to_json_struct).to eq({
                                        "address" => {
                                            "streetAddress" => 'street address',
                                            "addressCountry" => 'address country'
                                        },
                                            "geo" => {
                                                "latitude"  => 'latitude',
                                                "longitude" => 'longitude'
                                            }
                                      })
  end

end
