require 'rails_helper'

require_relative ('../../../lib/fake_addresses/csv_fake_addresses_writer')


RSpec.describe CSVFakeAddressesWriter do

  let(:addresses) {
    company_overtornea = create(:company, city: 'Övertorneå')

    addr1 = create(:address, addressable: (create :company))
    addr2 = create(:address, street_address: 'Matarengivägen 24',
                   post_code:                '957 31',
                   city:                     'Övertorneå',
                   addressable:              company_overtornea)
    [addr1, addr2]
  }


  describe 'writing out to a CSV file' do

    describe '.default_csv_filename' do

      it 'ends with .csv' do
        default_fn = CSVFakeAddressesWriter.default_csv_filename
        expect(default_fn.include?('.')).to be_truthy
        expect(default_fn.split('.').last).to eq('csv')
      end

      it 'puts a timestamp in the name' do
        default_fn = CSVFakeAddressesWriter.default_csv_filename
        expect(default_fn).to match(/\.\/fake-addresses-(\d\d\d\d-\d\d-\d\d-\d\d\d\d\d\d[-+]\d\d\d\d)\.csv/)
      end

    end


    describe '.address_csv_line' do

      let(:address_line) { CSVFakeAddressesWriter.address_csv_line(addresses.first) }
      it 'has same number of items as the header line' do
        expect(address_line.split(',').count).to eq(CSVFakeAddressesWriter.csv_header_str.split(',').count)
      end

      it 'quotes around strings' do
        expect(address_line).to match(/(.*),"(.*)","(.*)","(.*)","(.*)","(.*)","(.*)",(.*),(.*),(.*),(.*)/)
      end
    end


    it '.csv_header_str' do
      expect(described_class.csv_header_str).to eq('id,street_address,post_code,city,country,region_name,kommun_name,latitude,longitude,visibility,mail')
    end


    describe '.csv_output' do

      let(:csv_output) { CSVFakeAddressesWriter.csv_output(addresses) }

      it 'first line is the header' do
        expect(csv_output.split("\n").first).to eq(CSVFakeAddressesWriter.csv_header_str)
      end

      it 'one line for each address' do
        expect(csv_output.split("\n").count).to eq(1 + 2)
      end

      it 'only the header line if the list of addresses is empty' do
        empty_output = CSVFakeAddressesWriter.csv_output([])
        expect(empty_output.split("\n").first).to eq(CSVFakeAddressesWriter.csv_header_str)
        expect(empty_output.split("\n").count).to eq 1
      end

    end

  end #  describe 'writing out to a CSV file'

end
