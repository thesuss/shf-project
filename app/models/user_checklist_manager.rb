#--------------------------
#
# @class UserChecklistManager
#
# @desc Responsibility: Handle all behavior and queries for a UserChecklist associated with a User
#
# 2020-12-07  Business Rule: Everyone must always agree to the membership guidelines,
#   no matter when their term starts/ends, etc.
#   The only limiting factor is when the Membership Guidelines requirement started.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   1/23/20
#
#--------------------------

class UserChecklistManager

  def self.completed_membership_guidelines_checklist?(user)
    find_or_create_membership_guidelines_list_for(user)&.all_completed?
  end


  def self.find_or_create_membership_guidelines_list_for(user)
    found_guidelines = membership_guidelines_list_for(user)
    found_guidelines.nil? ? AdminOnly::UserChecklistFactory.create_member_guidelines_checklist_for(user) : found_guidelines
  end

  # @return [ nil | UserChecklist] - return nil if there aren't any,
  #   else return the most recently created one.
  #   _membership_guidelines_for_user_ returns only top level checklist (the roots of any nested checklists)
  def self.membership_guidelines_list_for(user)
    UserChecklist.membership_guidelines_for_user(user)&.last
  end


  # Gets the first incomplete guideline (checklist) for the user.
  # If the user does not have to complete the membership guidelines, return nil.
  # If there are no guidelines, return nil.
  # If there are no incomplete guidelines, return nil.
  #
  # Else return the first uncompleted checklist (since they are given to us here as sorted)
  # @return [Nil | UserChecklist]
  def self.first_incomplete_membership_guideline_section_for(user)
    not_completed_guidelines_for(user)&.first
  end


  def self.completed_guidelines_for(user)
    guidelines_for(user, :completed)
  end


  def self.not_completed_guidelines_for(user)
    # guideline_list.descendants.uncompleted.to_a
    guidelines_for(user, :uncompleted)
  end


  # Make one if it doesn't exist?  NO.  Just return empty list.
  # The selection_block is being used explictly so it's very clear.  (Could have also use yield.)
  def self.guidelines_for(user, completed_method = :completed)
    guideline_list = membership_guidelines_list_for(user) ? membership_guidelines_list_for(user) : {}
    return [] unless guideline_list.present?

    guideline_list.descendants&.send(completed_method).to_a&.sort_by { |kid| "#{kid.ancestry}-#{kid.list_position}" }
  end
end
