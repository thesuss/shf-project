require 'rails_helper'

RSpec.describe Adapters::AddressesIntoSchemaLocalBusiness do

  let(:given_address) { build(:address) }
  let(:mock_place_schema) { instance_double(SchemaDotOrg::Place) }
  let(:mock_addr_to_place_schema) { instance_double(Adapters::AddressToSchemaPlace, as_target: mock_place_schema) }
  let(:mock_postal_addr_schema) { instance_double(SchemaDotOrg::PostalAddress) }
  let(:mock_geo_coordinates_schema) { instance_double(SchemaDotOrg::GeoCoordinates) }
  let(:mock_addr_to_postal_address) { instance_double(Adapters::AddressToSchemaPostalAddress, as_target: mock_postal_addr_schema) }
  let(:mock_addr_to_geo_coordinates) { instance_double(Adapters::AddressToSchemaGeoCoordinates, as_target: mock_geo_coordinates_schema) }

  let(:mock_local_biz) { instance_double(SchemaDotOrg::LocalBusiness, {location: [], 'address=' => 'address', 'geo=' => 'geo'}) }


  describe '.set_address_properties' do
    before(:each) do
      allow(described_class).to receive(:set_main_address).with(given_address, mock_local_biz)
                                                          .and_return(mock_local_biz)
    end

    it 'sets the main address to the given address' do
      expect(described_class).to receive(:set_main_address).with(given_address, mock_local_biz)
      described_class.set_address_properties([], given_address, mock_local_biz)
    end

    it 'list of addresses is empty so no addresses are added to the location' do
      expect(described_class).not_to receive(:add_address_to_location)
      described_class.set_address_properties([], given_address, mock_local_biz)
    end

    context 'list of addresses is not empty' do
      context 'only 1 address in the list' do
        it 'no addresses are added to the business location (because the main address is used)' do
          expect(mock_local_biz).not_to receive(:location=)
          expect(described_class).not_to receive(:add_address_to_location)
          described_class.set_address_properties([given_address], given_address, mock_local_biz)
        end
      end

      context 'more than 1 address in the list' do
        it 'the business location is a new array of addresses, each address is added to it' do
          expect(mock_local_biz).to receive(:location=).and_return([])
          expect(described_class).to receive(:add_address_to_location).twice
          described_class.set_address_properties([given_address,given_address], given_address, mock_local_biz)
        end
      end
    end
  end


  describe '.set_main_address' do
    before(:each) do
      allow(Adapters::AddressToSchemaPostalAddress).to receive(:new).and_return(mock_addr_to_postal_address)
      allow(Adapters::AddressToSchemaGeoCoordinates).to receive(:new).and_return(mock_addr_to_geo_coordinates)
    end

    it 'adds the given address as a PostalAddress schema to the given local business' do
      expect(mock_local_biz).to receive(:address=).with(mock_postal_addr_schema)
      described_class.set_main_address(given_address, mock_local_biz)
    end

    it 'adds the given address as a GeoCoordinates schema to the given local business' do
      expect(mock_local_biz).to receive(:geo=).with(mock_geo_coordinates_schema)
      described_class.set_main_address(given_address, mock_local_biz)
    end
  end


  describe '.add_address_to_location' do
    it 'adds the given address as a AddressToSchemaPlace.as_target' do
      expect(Adapters::AddressToSchemaPlace).to receive(:new).with(given_address)
                                                   .and_return(mock_addr_to_place_schema)
      expect(mock_addr_to_place_schema).to receive(:as_target)
      described_class.add_address_to_location(given_address, [])
    end

    it 'returns the given location [Array] with the address schema added' do
      allow(Adapters::AddressToSchemaPlace).to receive(:new).with(given_address)
                                                             .and_return(mock_addr_to_place_schema)
      given_location_array = []
      expect(described_class.add_address_to_location(given_address, given_location_array)).to match_array([mock_place_schema])
    end
  end
end
