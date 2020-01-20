require 'ordered_ancestry_entry'

module AdminOnly

  class MasterChecklistError < StandardError
  end

  class CannotChangeAttributeError < MasterChecklistError
  end

  class HasCompletedUserChecklistsCannotChange < CannotChangeAttributeError
  end

  class CannotChangeUserVisibleInfo < CannotChangeAttributeError
  end


  #--------------------------
  #
  # @class MasterChecklist
  #
  # @desc Responsibility: This is the master list that is a template for
  #  UserChecklists that are created.  It is the source (blueprint) for the
  #  UserChecklists.
  #  By including OrderedAncestryEntry, it becomes an ordered and nested list.
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date 2019-12-01
  #
  #--------------------------

  class MasterChecklist < ApplicationRecord

    validates_presence_of :name
    validates_presence_of :displayed_text
    validates_presence_of :list_position

    before_update :can_be_changed?


    # Don't delete if there are any associated user_checklists.
    #
    # The before_destroy check is a failsafe in case
    # destroy is called outside a method that checks information and business logic
    # to see if the object can really be destroyed.
    before_destroy :can_be_destroyed?, prepend: true

    USER_CHECKLIST_CLASS = UserChecklist

    has_many :user_checklists, class_name: "#{USER_CHECKLIST_CLASS}", dependent: :destroy
    has_many :users, through: :user_checklists

    has_ancestry

    include OrderedAncestryEntry

    scope :completed_userchecklists, -> { where(id: USER_CHECKLIST_CLASS.completed.pluck(:id)) }
    scope :uncompleted_userchecklists, -> { where(id: USER_CHECKLIST_CLASS.uncompleted.pluck(:id)) }

    scope :in_use, -> { where(is_in_use: true) }
    scope :not_in_use, -> { where(is_in_use: false) }

    scope :top_level_checklists, -> { where(ancestry: nil) }
    scope :top_level_in_use, -> { top_level_checklists.in_use }


    # --------------------------------------------------------------------------

    def self.user_checklist_class
      USER_CHECKLIST_CLASS
    end


    # Return the entry and all children as an Array, sorted by list position and then name.
    #
    # @return [Array<MasterChecklist>] - an Array with the given node first, then its children sorted by the ancestry, list position, and then name.
    #
    def self.all_as_array_nested_by_name
      all_as_array(order: %w(name))
    end


    # The only attributes that can be changed if there are any completed user checklist
    #  are :is_in_use and :is_in_use_changed_at  (when :is_in_use was changed)
    #
    def self.change_with_completed_user_checklists?(attribute)
      attributes_can_change_with_completed.include?(attribute.to_sym)
    end


    # Cannot change a Master Checklist if the attribute is one that is displayed to users
    def self.change_with_uncompleted_user_checklists?(attribute)
      !attributes_displayed_to_users.include?(attribute.to_sym)
    end


    def self.attributes_can_change_with_completed
      [:is_in_use, :is_in_use_changed_at, :notes, :updated_at]
    end


    def self.attributes_displayed_to_users
      [:displayed_text, :description]
    end


    def self.top_level_next_list_position
      default_next_position = 1
      top_checklists = top_level_in_use
      top_checklists.empty? ? default_next_position : top_checklists.pluck(:list_position).max + 1
    end


    # -----------------------------------------


    def user_checklist_class
      self.class.user_checklist_class
    end


    # @return all children that have is_in_use set to true
    #
    def children_in_use
      self.ancestry_base_class.where(child_conditions).where(is_in_use: true)
    end


    def children_not_in_use
      self.ancestry_base_class.where(child_conditions).where(is_in_use: false)
    end


    def completed_user_checklists
      user_checklist_class.completed_for_master_checklist(self)
      # user_checklists.reject(&:completed?) #{ |user_checklist| user_checklist.completed? }
    end


    def uncompleted_user_checklists
      user_checklist_class.not_completed_for_master_checklist(self)
      # user_checklists.reject(&:completed?) #{ |user_checklist| user_checklist.completed? }
    end


    alias_method :not_completed_user_checklists, :uncompleted_user_checklists


    # @return [Array<AdminOnly::MasterChecklist>] - list of MasterChecklists that can be a parent to this one.
    #  Only those that are currently in use are returned.
    def allowable_parents(potential_parents = [])
      allowable_as_parents(potential_parents).select(&:is_in_use)
    end


    def toggle_is_in_use
      set_is_in_use(!is_in_use)
    end


    def set_is_in_use(in_use = true)

      # Use a Transaction so that any children or USER_CHECKLIST_CLASSs that are changed
      # are _rolled back_ if there is a failure at any point in the process.

      self.class.transaction do
        children.each { |child| child.set_is_in_use(in_use) }
        in_use ? change_to_being_in_use : delete_or_mark_unused
      end

    end


    def change_to_being_in_use
      change_is_in_use(true)
      add_to_parent_list_positions if ancestors?
    end


    def add_to_parent_list_positions
      # :insert is used by the OrderedListEntry.
      # Wrapping it in this method makes the intention clear
      # and helps to keep "insert" from being ambiguous
      parent.insert(self)
    end


    # The before_destroy check with can_be_destroyed? is a failsafe in case
    # destroy is called outside this method (with no business logic checks, etc.)
    def delete_or_mark_unused

      delete_uncompleted_user_checklists

      if can_delete?
        destroy
      else
        mark_as_no_longer_used
      end
    end


    def delete_uncompleted_user_checklists
      uncompleted_user_checklists.each { |uncompleted_uc| uncompleted_uc.delete }
    end


    def mark_as_no_longer_used
      change_is_in_use(false)
      parent.remove_child_from_list_positions(self) if ancestors? # don't delete from the db, just remove from the parent list
    end


    # REMOVE the entry from the list positions by (1) setting the child list position to 0
    # and (2) updating the list positions of all other children as if this
    # child was not in the list.
    #
    # Do NOT delete the child from the db (persistent store).
    #
    # This might be used if the removed entry needs to be flagged as "no longer in use" or "archived"
    # and remain in the database.
    #
    # This may lead to a situation where more than one child has the same list_position (e.g. position 0)
    # Only 1 child should be 'in use'; others can have the same list_position but not be in use ( = 'removed')
    #   -- This adds a variation to how a OrderedAncestryEntry is defined.
    #
    # @param entry [MasterChecklist] - the entry to 'removed' from the list positions
    # @return [Array] - children
    def remove_child_from_list_positions(entry)
      if children.include?(entry)
        decrement_child_positions(entry.list_position)
      end
      children
    end


    def can_be_destroyed?
      # throw :abort is required to stop the callback chain
      can_delete? ? true : (throw :abort)
    end


    def can_delete?
      !children? && !has_completed_user_checklists?
    end


    def change_is_in_use(new_value = false, changed_time = Time.zone.now)
      update(is_in_use: new_value, is_in_use_changed_at: changed_time)
    end


    # ----------------------


    # If there are any completed user checklists, cannot change it.
    #  it can be changed only if the attribute can be changed with completed user checklists associated
    #
    # If there are user checklists, but none are completed:
    #  it can be changed only if the attribute can be changed with uncompleted user checklists associated
    #
    #                                        | uncompleted: can   |                | completed: can
    # has User Checklist? | any uncompleted? | change attribute ? | any completed? | change attribute ? | can change?
    # --------------------+------------------+--------------------+----------------+--------------------|------------
    #   _false_           |   -              |      -             |  -             |                    | true
    #                     |                  |                    |                |                    |
    #   true              |   -              |      -             |  true          |  _true_            | true
    #   true              |   -              |      -             |  false         |  _false_           | false
    #                     |                  |                    |                |                    |
    #   true              |   true           |      _true_        |  false         |                    | true
    #   true              |   true           |      _false_       |  false         |                    | false
    #
    #    underlined (_..._) items are the key to determining the result
    #
    # TODO Rails 6.0+: verify that changed_attributes still applies. Rails 6.0+ has simplified tracking changes to attributes: Dirty https://api.rubyonrails.org/classes/ActiveModel/Dirty.html
    #
    # Raise exceptions - which halts further callbacks and can then be used to display a message (or whatever action should be taken)
    # if changes to these attributes cannot be made.
    #
    def can_be_changed?(attributes_to_change = [])

      return false unless is_in_use
      return true unless user_checklists.any?

      # '|' = [Array] union of the keys and attributes to change

      if has_completed_user_checklists?
        can_change_with_completed = (changed_attributes.keys | attributes_to_change).inject(true) { |can_change, this_attribute| can_change && change_with_completed_user_checklists?(this_attribute) }
        raise HasCompletedUserChecklistsCannotChange unless can_change_with_completed
      end

      can_change_with_uncompleted = (changed_attributes.keys | attributes_to_change).inject(true) { |can_change, this_attribute| can_change && change_with_uncompleted_user_checklists?(this_attribute) }
      raise CannotChangeUserVisibleInfo unless can_change_with_uncompleted

      true # should always be true (can be changed) if we got to here
    end


    def change_with_completed_user_checklists?(attribute)
      self.class.change_with_completed_user_checklists?(attribute)
    end


    def change_with_uncompleted_user_checklists?(attribute)
      raise CannotChangeUserVisibleInfo unless self.class.change_with_uncompleted_user_checklists?(attribute)
      true
    end


    def has_completed_user_checklists?
      user_checklist_class.completed_for_master_checklist(self).count > 0
    end


    # @param [String] prefix - the string that represents one level of depth; is
    #   prepended :depth times in front of the name
    # @return [String] - a string showing the depth of this entry and the name
    def display_name_with_depth(prefix: '-')
      "#{prefix * depth} #{name}"
    end


  end

end
