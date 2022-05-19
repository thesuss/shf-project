# frozen_string_literal: true

module AdminOnly

  #--------------------------
  #
  # @class MasterChecklistChangePolicy
  #
  # @desc Responsibility: Know if a MasterChecklist can be changed or destroyed and
  #  responds to questions about it.
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date 2020-01-23
  #
  #--------------------------
  #
  class MasterChecklistChangePolicy


    # Delegate these instance methods to our class methods
    delegate :attributes_can_change_with_completed,
             :attributes_displayed_to_users,
             :change_with_completed_user_checklists?,
             :change_with_uncompleted_user_checklists?,
             to: :class


    # ===================================================================================


    def self.attributes_can_change_with_completed
      [:is_in_use, :is_in_use_changed_at, :notes, :updated_at]
    end


    def self.attributes_displayed_to_users
      [:displayed_text, :description, :list_position, :ancestry]
    end


    # The only attributes that can be changed if there are any completed user checklist
    #  are :is_in_use and :is_in_use_changed_at  (when the attribute :is_in_use was changed)
    def self.change_with_completed_user_checklists?(attribute)
      attributes_can_change_with_completed.include?(attribute.to_sym)
    end

    # Cannot change a Master Checklist if the attribute is one that is displayed to users
    def self.change_with_uncompleted_user_checklists?(attribute)
      !attributes_displayed_to_users.include?(attribute.to_sym)
    end



    # ------------------------------------------------------------------------------------


    # Cannot make any "major" changes if there are any user checklists.
    # "major" changes are any that users see or that UserChecklists are based on.
    # (as of 2020-01-20 this means that only notes and the name that administrators see can be changed.)
    #
    # The difference between this method and can_be_changed? is can_be_changed?
    # considers whether specific attributes can be changed.
    def self.no_more_major_changes?(master_checklist)
      master_checklist.user_checklists.any?
    end


    # Cannot change if there are any user checklists.
    def self.can_add_child?(master_checklist)
      !no_more_major_changes?(master_checklist)
    end


    # If there are any completed user checklists, cannot change it.
    #  it can be changed only if the attribute can be changed with completed user checklists associated
    #
    # If there are user checklists, but none are completed:
    #  it can be changed only if the attribute can be changed with uncompleted user checklists associated
    #
    # TODO Rails 6.0+: verify that changed_attributes still applies. Rails 6.0+ has simplified tracking changes to attributes: Dirty https://api.rubyonrails.org/classes/ActiveModel/Dirty.html
    #
    # Raise exceptions - which halts further callbacks and can then be used to display a message (or whatever action should be taken)
    # if changes to these attributes cannot be made.
    #
    def self.can_be_changed?(master_checklist, attributes_to_change = [])

      return false unless master_checklist.is_in_use
      return true unless master_checklist.user_checklists.any?

      # '|' = [Array] union of the keys and attributes to change

      if master_checklist.has_completed_user_checklists?
        can_change_with_completed = (master_checklist.changed_attributes.keys | attributes_to_change).inject(true) { |can_change, this_attribute| can_change && change_with_completed_user_checklists?(this_attribute) }
        raise HasCompletedUserChecklistsCannotChange unless can_change_with_completed
      end

      can_change_with_uncompleted = (master_checklist.changed_attributes.keys | attributes_to_change).inject(true) { |can_change, this_attribute| can_change && change_with_uncompleted_user_checklists?(this_attribute) }
      raise CannotChangeUserVisibleInfo unless can_change_with_uncompleted

      true # should always be true (can be changed) if we got to here
    end


    def self.can_be_destroyed?(master_checklist)
      # throw :abort is required to stop the callback chain
      can_delete?(master_checklist) ? true : (throw :abort)
    end


    # Cannot delete if
    # it is in use OR
    # there are _any_ user checklists associated with it (completed or not) OR
    # there is a child that cannot be deleted
    def self.can_delete?(master_checklist)
      (!master_checklist.is_in_use && !master_checklist.user_checklists.any?)  && master_checklist.children.map(&:can_delete?).all?
    end

  end

end
