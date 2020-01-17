require_relative './simple_class_yaml_seeder'

module Seeders
  #--------------------------
  #
  # @class FileDeliveryMethodsSeeder
  #
  # @desc Responsibility: Seed FileDeliveryMethods to/from a YAML file
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   01/16/20
  #
  #--------------------------
  #
  class FileDeliveryMethodsSeeder < SimpleClassYamlSeeder

    YAML_FILENAME = 'file-delivery-methods-data.yml'
    SEEDED_CLASS = AdminOnly::FileDeliveryMethod

  end

end
