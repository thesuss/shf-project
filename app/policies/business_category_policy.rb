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


  def index?
    is_admin?
  end


  def update?
    is_admin?
  end


  def edit?
    is_admin?
  end


end