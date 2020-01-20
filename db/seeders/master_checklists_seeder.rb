require 'yaml'
require_relative 'ancestry_ordered_seeder'

module Seeders

#--------------------------
#
# @class MasterChecklistsSeeder
#
# @desc Responsibility: Seed MasterChecklists, their items and sub-checklists from a YAML file
#   Can also write hardcoded data out to the YAML file. (can write out and read in)
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-11-29
#
#--------------------------
  class MasterChecklistsSeeder < AncestryOrderedSeeder

    YAML_FILENAME = 'master-checklists.yml'
    SEEDED_CLASS = AdminOnly::MasterChecklist


    def self.create_ordered_entry(yaml_entry, parent_ordered_entry: nil)
      SEEDED_CLASS.create!(name: yaml_entry[:name],
                           displayed_text: yaml_entry[:displayed_text],
                           description: yaml_entry[:description],
                           list_position: yaml_entry[:list_position] ? yaml_entry[:list_position] : 0,
                           parent: parent_ordered_entry)
    end

  end

end
