require_relative './simple_class_yaml_seeder'

module Seeders
  #--------------------------
  #
  # @class KommunsSeeder
  #
  # @desc Responsibility: Seed Kommuns to/from a YAML file
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   01/16/20
  #
  #--------------------------
  #
  class KommunsSeeder < SimpleClassYamlSeeder

    YAML_FILENAME = 'kommuns-data.yml'
    SEEDED_CLASS = Kommun

  end

end
