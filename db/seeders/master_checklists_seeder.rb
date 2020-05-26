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



    def self.create_ordered_entry(yaml_entry, parent_ordered_entry: nil, log: nil)
      associations = find_or_create_associations(yaml_entry)
      find_or_create_object(yaml_entry, associations, parent_ordered_entry: parent_ordered_entry, log: log)
    end


    # @return [Array<Hash>] - all of serialized objects as a serialized Hash (YAML)
    #
    def self.serialized_objects
      seeded_class.arrange_serializable(order: [:ancestry, :list_position]) do |parent, children|
        parent.as_json(include: [:master_checklist_type]).merge({ children: children })
      end
    end

    # @return [MasterChecklist | nil] - the object created (return nil if nothing was created)
    def self.find_or_create_object(obj_yaml_entry, associations_info = {}, parent_ordered_entry: nil, log: nil)

      obj_yaml_entry.delete(:id)
      obj_yaml_entry.delete(:master_checklist_type_id)
      obj_yaml_entry.delete(:master_checklist_type)

      entry_name = obj_yaml_entry[:name]
      found_checklist = seeded_class.find_by(name: entry_name)
      if found_checklist
        info_str = " INFO: #{self.name}.#{__method__} : #{seeded_class} already exists; not seeded: [id] name = [#{found_checklist.id}] #{found_checklist.name}"
        tell(info_str)
        log_str(info_str, log: log)
        nil # nothing was created; no created object is returned
      else
        seeded_class.create!(name: entry_name,
                             displayed_text: obj_yaml_entry[:displayed_text],
                             description: obj_yaml_entry[:description],
                             list_position: obj_yaml_entry[:list_position] ? obj_yaml_entry[:list_position] : 0,
                             parent: parent_ordered_entry,
                             master_checklist_type: associations_info[:master_checklist_type]
        )
      end
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
