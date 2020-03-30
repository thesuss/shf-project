class UserChecklistPolicy < ApplicationPolicy

  def new?
    not_a_visitor?
  end


  def create?
    new?
  end


  def show?
    admin_or_owner?
  end


  def show_progress?
    show?
  end


  def index?
    not_a_visitor?
  end


  def update?
    not_a_visitor?
  end


  def edit?
    update?
  end


  def destroy?
    admin_or_owner?
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
