#!/usr/bin/ruby

require 'smarter_csv'

#--------------------------
#
# @class CSVFakeAddressesReader
#
# @desc Responsibility: Can read fake addresses data from a CSV file and create
#   Addresses.  This does _not_ save the Addresses because they are not valid:
#   They do not have an 'Addressabe' (e.g a Company) associated with them.
#
# This assumes that the CSV file is in this format:
#
# id,street_address,post_code,city,country,region_name,kommun_name,latitude,longitude,visibility,mail
#
# * Note that there is NO ADDRESSABLE id or type
#
# * Note that that REGION must be a _name_ (not an id) so that it can be easily
#   matched to an existing region.
#
# * Note that the KOMMUN must be a _name_ (not an id) so that it can be easily
#   matched to an existing kommun.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2018-12-12
#
# @file csv_fake_addresses_reader.rb
#
#--------------------------


class CSVFakeAddressesReader

  DEFAULT_CSV_NAME_START = './fake-addresses-'
  DEFAULT_CSV_EXT        = '.csv'

  DEFAULT_REGION_NAME = 'Stockholm'
  DEFAULT_KOMMUN_NAME = 'Stockholm'


  def self.read_from_csv_file(csv_filename)

    csv_data = []

    File.open(File.absolute_path(csv_filename), "r:bom|utf-8") do | csv_file |
      csv_data = SmarterCSV.process(csv_file) unless File.empty?(csv_file)
    end

    create_addresses(csv_data)
  end


  def self.create_addresses(csv_data)
    addresses = []
    csv_data.each{ | addr_data | addresses << create_address(addr_data) }
    addresses
  end


  # Instantiate an address from a hash.
  # Look up the Region using the :region_name
  # Look up the Kommun using the :kommun_name
  #
  # It is _not_ saved because there is no valid 'addressable' (e.g. Company)
  # associated with it.
  def self.create_address(csv_address_hash)
    found_region = find_region_from_name(csv_address_hash[:region_name])
    found_kommun = find_kommun_from_name(csv_address_hash[:kommun_name])

    Address.new( create_hash_with_region_kommun_ids(csv_address_hash,
                                                   found_region,
                                                   found_kommun) )
  end


  def self.create_hash_with_region_kommun_ids(original_hash, region, kommun)

    hash_with_region_and_kommun_ids = original_hash.reject{ |key, _value| key == :region_name || key == :kommun_name}
    hash_with_region_and_kommun_ids[:region_id] = region.id
    hash_with_region_and_kommun_ids[:kommun_id] = kommun.id
    hash_with_region_and_kommun_ids
  end


  def self.find_region_from_name(region_name)
    find_from_name_in_class(region_name, Region, DEFAULT_REGION_NAME)
  end


  def self.find_kommun_from_name(kommun_name)
    find_from_name_in_class(kommun_name, Kommun, DEFAULT_KOMMUN_NAME)
  end


  # Create the full default filename for the CSV file. Puts a timestamp
  # into the name
  def self.default_csv_filename
    "#{DEFAULT_CSV_NAME_START}#{Time.now.strftime("%F-%H%M%S%z")}#{DEFAULT_CSV_EXT}"
  end


  # --------------


  def self.find_from_name_in_class(name, klass, default_name)

    item = klass.find_by(name: name)

    if item.nil?
      # if this item does not exist in the db,
      # there is a read problem and a legitimate error will be raised
      item = klass.find_by!(name: default_name)
    end

    item
  end


end # CSVFakeAddressesReader

