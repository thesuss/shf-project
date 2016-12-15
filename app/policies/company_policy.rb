class CompanyPolicy < ApplicationPolicy


  def show?
    true
  end

  def index?
    true
  end

  def new?
    is_admin?
  end

  def create?
    new?
  end

  def update?
   is_admin? || is_in_company?
  end



  private
  def is_admin?
    @user.admin? if @user
  end

  def is_in_company?
    @user && @user.is_in_company_numbered?(@record.company_number)
  end
end