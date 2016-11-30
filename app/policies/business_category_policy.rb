class BusinessCategoryPolicy < ApplicationPolicy

  def new?
    is_admin?
  end

  def create?
    new?
  end

  def show?
    true
  end

end