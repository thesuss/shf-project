#!/usr/bin/ruby

#--------------------------
#
# @class CSVFakeAddressesWriter
#
# @desc Responsibility: Can write out a fake addresses  CSV file.
#
# This writes the CSV file is in this format:
#
# id,street_address,post_code,city,country,region_name,kommun_name,latitude,longitude,visibility,mail
#
# * Note that there is NO ADDRESSABLE id or type
#
# * Note that that REGION is a _name_ (not an id) so that it can be easily
#   matched to an existing region.
#
# * Note that the KOMMUN is a _name_ (not an id) so that it can be easily
#   matched to an existing kommun.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2018-12-12
#
# @file csv_fake_addresses_writer.rb
#
#--------------------------


class CSVFakeAddressesWriter

  DEFAULT_CSV_NAME_START = './fake-addresses-'
  DEFAULT_CSV_EXT        = '.csv'


  # @param addresses [list of Address] -  the list of addresses that will be written out
  #         Note that the region name and kommun name is required for each
  #         address.  Thus it's most efficient if the db query used to
  #         gather the addresses includes both _region_ and _kommun_
  #          Ex:
  #             addresses = Address.includes(:kommun, :region).all
  #             CSVFakeAddressesWriter(addresses)
  #
  # @param filename [String] - the full path of the file to write out to
  def self.write_to_csv_file(addresses = [], filename = default_csv_filename)

    File.open(filename, 'w') do |csv_file|
      csv_file.puts csv_output(addresses)
    end

  end


  # Create the output for the CSV file. This is one big UTF-8 string.
  # The first line is a CSV header.
  # Each remaining line is the CSV line for an address
  #
  # @param addresses [List of Address] - the Addresses to write out
  # @return [String] - the CSV for all of the Addresses
  def self.csv_output(addresses)
    out_str = ''
    out_str << csv_header_str + "\n"
    addresses.each { |address| out_str << (address_csv_line(address) + "\n") }
    out_str.encode('UTF-8')
  end


  # the header string for the CSV file
  # @return [String] - the header string
  def self.csv_header_str
    "id,street_address,post_code,city,country,region_name,kommun_name,latitude,longitude,visibility,mail"
  end


  # create the string for an address in our CSV format
  # Note:
  #   * the region is the _region name_ (not the id)
  #   * the kommun is the _kommun name_ (not the id)
  #   * the :addressable_id and :addressable_name are _not_ written out
  #
  # @param address [Address] - the Address to create the CSV string for
  # @return [String] - the CSV string for the address
  def self.address_csv_line(address)
    "#{address.id}," +
        "\"#{address.street_address}\"," +
        "\"#{address.post_code}\"," +
        "\"#{address.city}\"," +
        "\"#{address.country}\"," +
        "\"#{address.region.name}\"," +
        "\"#{address.kommun.name}\"," +
        "#{address.latitude}," +
        "#{address.longitude}," +
        "#{address.visibility}," +
        "#{address.mail}"
  end


  # Create the full default filename for the CSV file. Puts a timestamp
  # into the name
  # @return [String] - the filename with the current time appended to
  #                     the default start of the filename
  def self.default_csv_filename
    "#{DEFAULT_CSV_NAME_START}#{Time.now.strftime("%F-%H%M%S%z")}#{DEFAULT_CSV_EXT}"
  end


end # CSVFakeAddressesWriter

