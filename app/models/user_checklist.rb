require 'ordered_ancestry_entry'

#--------------------------
#
# @class UserChecklist
#
# @desc Responsibility: track the status of a checklist item (an AdminOnly::MasterChecklist)
# for a particular User
#
# Note: If a list has sublists (children), it cannot be manually set to un-/completed.
#   The completion status is set automatically based on the children (e.g. if they are are complete or not).
#
#
# What happens when you change the master list?  does it reflect that?
#   - No:  SHF board decided that when a person renews again (or has reason to see the checklist again),
#     the users will see the new/updated/changed information from a master list.  (Otherwise we have to notify each user of the change(s) each time.)
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date  2019-12-04
#
#--------------------------
class UserChecklist < ApplicationRecord

  belongs_to :user
  belongs_to :master_checklist, class_name: "AdminOnly::MasterChecklist", foreign_key: "master_checklist_id"


  has_ancestry

  include OrderedAncestryEntry

  # --------------------------------------------------------------------------

  scope :by_ancestry, -> { order(ancestry: :desc) }


  def self.completed
    where.not(date_completed: nil)
  end


  def self.uncompleted
    where(date_completed: nil)
  end


  def self.completed_by_user(user)
    where(user: user).completed
  end


  def self.not_completed_by_user(user)
    where(user: user).uncompleted
  end


  def self.completed_for_master_checklist(master_checklist)
    where(master_checklist: master_checklist).completed
  end


  def self.not_completed_for_master_checklist(master_checklist)
    where(master_checklist: master_checklist).uncompleted
  end


  # Add .includes to the query used to get all descendants to help avoid N+1 queries
  def descendants depth_options = {}
    super.includes(:master_checklist).includes(:user)
  end


  # Add .includes to the query used to get all descendants to help reduce N+1 queries
  def children
    super.includes(:master_checklist).includes(:user)
  end


  # --------------------------------------------------------------------------

  def completed?
    !date_completed.blank? && descendants_completed?
  end


  def descendants_completed?
    descendants.inject(:true) { |is_completed, descendant| descendant.completed? && is_completed }
  end


  # @return [Array<UserChecklist>] - the list of all items that are completed, including self and children
  def completed
    all_complete = descendants.completed.to_a
    all_complete.prepend self unless date_completed.blank?
    all_complete
  end


  # @return [Array<UserChecklist>] - the list of all items that are not completed, including self and children
  def uncompleted
    all_uncomplete = descendants.uncompleted.to_a
    all_uncomplete.prepend self if date_completed.blank?
    all_uncomplete
  end


  # Toggle whether or not this is completed and return a list of all UserChecklists changed because of it.
  # Use the current completed state to determine what the new state should be.
  #
  # @param [Time] new_date_complete- when the entry was completed. default = Time.zone.now
  # @return [Array<UserChecklist>] - a list of all user checklists that were changed
  #
  def all_changed_by_completion_toggle(new_date_complete = Time.zone.now)
    completed? ? all_toggled_to_uncomplete : all_toggled_to_complete(new_date_complete)
  end


  # ===================================================================================

  protected


  # Set this to uncompleted (not completed) and also update ancestors if needed.
  #
  # If already uncomplete, do nothing
  #   (this might happen if we are an ancestor of what kicked off the all_toggled_to_uncomplete)
  #    if we are uncomplete, our ancestor must also be uncomplete so there is no need to update them.
  # Else change to uncomplete and also update ancestors
  #
  # @return [Array<UserChecklist>] - a list of all user checklists that were changed
  #
  def all_toggled_to_uncomplete
    items_changed = []

    unless date_completed.nil?
      update(date_completed: nil) # we ignore new_date_complete in case nothing was passed in
      items_changed << self
      items_changed.concat(parent.all_toggled_to_uncomplete) if has_parent?
    end

    items_changed
  end


  # Set this to completed and also update ancestors if needed.
  #
  # If already complete
  #   (this might happen if we are an ancestor of what kicked off the all_toggled_to_complete)
  #   update the completion date anyway (because one of our children might have a new completion date.  This shouldn't happen, but we keep this here to ensure data consistency)
  #
  # Can only change to complete if all of our descendants are complete.
  #
  # Update our ancestors.
  #
  # @param [Time] new_date_complete- when the entry was completed. default = Time.zone.now
  # @return [Array<UserChecklist>] - a list of all user checklists that were changed
  #
  def all_toggled_to_complete(new_date_complete = Time.zone.now)
    items_changed = []

    if descendants_completed?
      update(date_completed: new_date_complete)
      items_changed << self
      items_changed.concat(parent.all_toggled_to_complete(new_date_complete)) if has_parent?
    end

    items_changed
  end

end
