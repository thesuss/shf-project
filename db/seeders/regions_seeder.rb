require_relative './simple_class_yaml_seeder'

module Seeders
  #--------------------------
  #
  # @class RegionsSeeder
  #
  # @desc Responsibility: Seed Regions to/from a YAML file OR the 'city-state' gem.
  #   Can use the 'city-state' gem for a list of regions (name and ISO code).
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   01/16/20
  #
  #--------------------------
  #
  class RegionsSeeder < SimpleClassYamlSeeder

    YAML_FILENAME = 'regions-data.yml'
    SEEDED_CLASS = Region


    # ----------------------------------------------------------------

    # Create a region for each 'state' in the city-state gem.
    # Note this just loads and creates new Regions. (You may end up with duplicates if there are already Regions that exist.)
    def self.load_from_city_state_gem
      CS.states(:se).each_pair { |k, v| Region.create(name: v, code: k.to_s) }
    end


    # Create 2 regions:  'Sverige' (Sweden) and 'Online'.
    #  These are used to provide a region if a company only has an online presences but no physical store/location,
    # and to provide a default primary region (Sverige) for companies.
    #
    def self.create_sverige_and_online_regions
      Region.create(name: 'Sverige', code: nil)
      Region.create(name: 'Online', code: nil)
    end

  end

end
