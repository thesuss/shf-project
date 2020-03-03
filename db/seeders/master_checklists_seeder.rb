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


    # FIXME
    def self.create_ordered_entry(yaml_entry, parent_ordered_entry: nil)
      # SEEDED_CLASS.create!(name: yaml_entry[:name],
      #                      displayed_text: yaml_entry[:displayed_text],
      #                      description: yaml_entry[:description],
      #                      list_position: yaml_entry[:list_position] ? yaml_entry[:list_position] : 0,
      #                      parent: parent_ordered_entry)

      associations = find_or_create_associations(yaml_entry)
      find_or_create_object(yaml_entry, associations, parent_ordered_entry: parent_ordered_entry)

    end


    # @return [Array<Hash>] - all of serialized objects as a serialized Hash (YAML)
    #
    def self.serialized_objects
      seeded_class.arrange_serializable(order: [:ancestry, :list_position]) do |parent, children|
        parent.as_json(include: [:master_checklist_type]).merge({ children: children })
      end
    end


    def self.find_or_create_object(obj_yaml_entry, associations_info = {}, parent_ordered_entry: nil)

      obj_yaml_entry.delete(:id)
      obj_yaml_entry.delete(:master_checklist_type_id)
      obj_yaml_entry.delete(:master_checklist_type)

      master_checklist = seeded_class.find_or_create_by!(name: obj_yaml_entry[:name]) do |new_master_checklist|

        new_master_checklist.displayed_text = obj_yaml_entry[:displayed_text]
        new_master_checklist.description = obj_yaml_entry[:description]
        new_master_checklist.list_position = obj_yaml_entry[:list_position] ? obj_yaml_entry[:list_position] : 0
        new_master_checklist.parent = parent_ordered_entry

        new_master_checklist.master_checklist_type = associations_info[:master_checklist_type]
        new_master_checklist
      end

      master_checklist
    end


    def self.find_or_create_associations(yaml_entry)

      master_checklist_type_info = yaml_entry.delete(:master_checklist_type)
      assoc_master_checklist_type = AdminOnly::MasterChecklistType.find_or_create_by!(name: master_checklist_type_info[:name]) do |new_master_checklist_type|
        new_master_checklist_type.name = master_checklist_type_info[:name]
        new_master_checklist_type.description = master_checklist_type_info[:description]
        new_master_checklist_type
      end

      { master_checklist_type: assoc_master_checklist_type }
    end


    def self.seeded_class
      self::SEEDED_CLASS
    end
  end

end
