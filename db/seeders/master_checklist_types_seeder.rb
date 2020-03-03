require_relative './simple_class_yaml_seeder'

module Seeders
  #--------------------------
  #
  # @class MasterChecklistTypesSeeder
  #
  # @desc Responsibility: Seed MasterChecklistTypes to/from a YAML file
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2020-01-22
  #
  #--------------------------
  #
  class MasterChecklistTypesSeeder < SimpleClassYamlSeeder

    YAML_FILENAME = 'master-checklist-types-data.yml'
    SEEDED_CLASS = AdminOnly::MasterChecklistType

  end

end
