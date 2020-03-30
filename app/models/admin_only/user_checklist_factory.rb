module AdminOnly

  class UserChecklistFactoryError < StandardError
  end

  class UserChecklistTemplateNotFoundError < UserChecklistFactoryError
  end


  #--------------------------
  #
  # @class UserChecklistFactory
  #
  # @desc Responsibility: Creates UserChecklists on demand based on a MasterChecklist
  #
  #
  # ex:  What if in 2020 we include an item in the Membership Ethical Guidelines, but in
  #        2021 that item  (item # 1.1.1) is no longer needed?  Or something is added?   (item # 1.7.1)
  #         - what do the users from 2020 see?  Will they no longer see item # 1.1.1?  Will they ever see # 1.7.1?
  #
  # What happens when you change the (master) checklist list? Is the change reflected/visible/available to a UserChecklist?
  #   Attributes (instance variables):
  #     Name?
  #     Displayed Text?
  #     list_position (order)
  #   Ancestry
  #     parent, children
  #
  # What happens if the master list is deleted?  (should not be able to if there is a UserChecklist associated with it)
  #
  #
  # TODO - need a diagram, words,. document to explain this.
  #  - will need to be able to show this clearly to an admin (eventually.)
  #   -> does the MasterChecklist entry need a way to track notes from the Admin?
  #      e.g.
  #      admin_note: "In 2020 we used this as the list of membership steps.
  #                   But in December 2020 we revised it and created a new list.
  #                   That new list is 'Getting to Membership' (that's the text displayed to the user)
  #                   and the (admin only) name is 'Getting to Membership - 2021' "
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   12/21/19
  #
  #--------------------------
  #
  class AdminOnly::UserChecklistFactory


    # TODO - Eventually get this from AppConfiguration info?
    BECOME_A_MEMBER_LIST_NAME = 'Become a Member'

    # ------------------------------------------------------------


    # @return [UserChecklist] - the root of the created member guidelines
    def self.create_member_guidelines_checklist_for(user)

      # Get the SHF Membership Guidelines Checklist
      # If the checklist is not found, raise an error and be sure to send a notification!
      guidelines_template = get_member_guidelines_checklist_template

      if guidelines_template
        create_nested_lists_for_user_from_master_checklists([guidelines_template], user).last
      else
        # TODO i18n error message
        raise UserChecklistTemplateNotFoundError, "Membership Guidelines checklist template (AdminOnly::MasterChecklist) Not Found!  #{__method__}"
      end
    end


    # TODO The list to use should eventually be set by the admin (in AppConfiguration?)  Hardcoded for now.
    def self.get_member_guidelines_checklist_template
      AdminOnly::MasterChecklist.latest_membership_guideline_master
    end


    # TODO The list to use should eventually be set by the admin (in AppConfiguration?)  Hardcoded for now.
    def self.create_membership_checklist_for(user)

      # Get the membership Checklist
      # If membership checklist is not found, raise an error and be sure to send a notification!
      membership_template = get_membership_checklist_template
      if membership_template
        create_nested_lists_for_user_from_master_checklists([membership_template], user).last
      else
        # TODO i18n error message
        raise UserChecklistTemplateNotFoundError, "Membership checklist template (AdminOnly::MasterChecklist) Not Found!  #{__method__}"
      end
    end


    # TODO This should eventually be handled elsewhere - by AppConfiguration?.  Hardcoded for now.
    def self.get_membership_checklist_template
      AdminOnly::MasterChecklist.find_by(name: BECOME_A_MEMBER_LIST_NAME)
    end


    # Given a checklist master (e.g. AdminOnly::MasterChecklist), create a UserChecklist
    # for the user.  Reference all children from the checklist master so there is a
    # UserChecklist entry for every item, including all children ( = nested lists)
    #
    # @param [Array<AdminOnly::MasterChecklist>] list_of_checklistmaster_entries - the original checklist to use as the bases for UserChecklist entry(-ies)
    # @param [User] user - the user this is for (who will/won't be completing the entry(-ies) in the UserChecklist)
    #
    # @return [Array<UserChecklist>] - the ordered list of UserChecklist entries, root (or all top level) is the last item on the list
    #
    def self.create_nested_lists_for_user_from_master_checklists(list_of_checklistmaster_entries, user)

      # return an empty list if the arguments are empty or nil
      return [] if !orig_list_valid?(list_of_checklistmaster_entries) || user.nil?

      list = []
      list_of_checklistmaster_entries.each do |master_checklist|
        list.concat(create_for_user_from_master_checklist(user, master_checklist))
      end
      list
    end


    def self.create_for_user_from_master_checklist(user, master_checklist, user_checklist_parent = nil)
      list = []

      new_user_checklist = create_unnested_for_user_from_master(user, master_checklist, user_checklist_parent)

      master_checklist.children.each do |master_checklist_child|
        list.concat(create_for_user_from_master_checklist(user, master_checklist_child, new_user_checklist))
      end

      list << new_user_checklist
      list
    end


    #
    # Copy the name from master_checklist.displayed_text
    # Copy the description from master_checklist.description
    #
    def self.create_unnested_for_user_from_master(user, master_checklist, user_checklist_parent = nil)
      valid_list_position = master_checklist.list_position.blank? ? 0 : master_checklist.list_position
      UserChecklist.create!(master_checklist: master_checklist, user: user,
                            name: master_checklist.displayed_text,
                            description: master_checklist.description,
                            list_position: valid_list_position,
                            parent: user_checklist_parent)

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
