require 'rails_helper'


RSpec.describe SchemaDotOrg::GeoCoordinates, type: :model do

  let(:item) {
    geo = described_class.new
    geo.latitude = 'latitude value'
    geo.longitude = 'longitude value'
    geo
  }


  it '_to_json_struct' do
    expect(item._to_json_struct).to eq({
                                          "latitude"  => 'latitude value',
                                          "longitude" => 'longitude value'
                                      })
  end

end
