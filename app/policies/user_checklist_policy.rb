class UserChecklistPolicy < ApplicationPolicy


  def index?
    user.admin?
  end


  def new?
    not_a_visitor?
  end


  def create?
    new?
  end


  def show?
    user.admin?
  end


  def show_progress?
    admin_or_owner?
  end


  def update?
    not_a_visitor?
  end


  def edit?
    update?
  end

  # TODO  is this correct?  shouldn't it be admin only?  What happens when a User or Member is destroyed?/deleted?
  def destroy?
    user.admin_or_owner?
  end


  def all_changed_by_completion_toggle?
    update?
  end


  def set_complete_including_kids?
    update?
  end


  def set_uncomplete_including_kids?
    update?
  end
end
