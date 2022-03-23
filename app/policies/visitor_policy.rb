class VisitorPolicy < ApplicationPolicy

  def index?
    false
  end

  def edit_status?
    false
  end

  def show?
    false
  end

  def toggle_membership_package_sent?
    false
  end

end
