module AdminOnly

  #--------------------------
  #
  # @class AdminOnly::MasterChecklistFactory
  #
  # @desc Responsibility: Creates MasterChecklists
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2020-01-23
  #
  #--------------------------
  #
  class AdminOnly::MasterChecklistFactory


    # Given a LIST of AdminOnly::MasterChecklists,
    # create a copy (clone) of each MasterChecklist.
    # Reference all children from the checklist master so there is a
    # new cloned entry for every item, including all children ( = nested lists)
    #
    # @param [Array<AdminOnly::MasterChecklist>] list_of_checklistmaster_entries - the original checklist to use as the bases for UserChecklist entry(-ies)
    #
    # @return [Array<AdminOnly::MasterChecklist>] - list of the new cloned MasterChecklist (with all of the children cloned too)
    #
    def self.clone_lists(list_of_checklistmaster_entries)

      # return an empty list if the arguments are empty or nil
      return [] unless orig_list_valid?(list_of_checklistmaster_entries)

      list = []
      list_of_checklistmaster_entries.each do |master_checklist|
        list.concat(clone(master_checklist))
      end
      list
    end


    #
    # TODO why return a list? why not the root?
    #
    def self.clone(master_checklist, checklist_parent = nil)
      new_checklist = create_unnested_from_master(master_checklist, checklist_parent)
      master_checklist.children.each do |master_checklist_child|
        clone(master_checklist_child, new_checklist)
      end
      new_user_checklist
    end



    # Create a copy of the given master_checklist.
    # Set the parent to the given checklist_parent.  Do not do anything with children.
    # Do not copy the notes
    # Set is_in_use to true
    #
    def self.create_unnested_from_master(master_checklist, checklist_parent = nil)
      valid_list_position = master_checklist.list_position.blank? ? 0 : master_checklist.list_position

      MasterChecklist.create!(name: master_checklist.name,
                              displayed_text: master_checklist.displayed_text,
                              description: master_checklist.description,
                              list_position: valid_list_position,
                              parent: checklist_parent,
                              ancestry: master_checklist.ancestry,
                              is_in_use: true,
                              master_checklist_type: master_checklist.master_checklist_type)
    end


    def self.orig_list_valid?(orig_list)
      if orig_list.nil? || !orig_list.respond_to?(:each) || orig_list.empty?
        false
      else
        true
      end
    end
  end

end
