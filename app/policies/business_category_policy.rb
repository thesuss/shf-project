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


  def destroy?
    is_admin?
  end


  private
  def is_admin?
    @user.admin? if @user
  end
end