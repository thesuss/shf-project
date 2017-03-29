class ShfDocumentPolicy < ApplicationPolicy


  def index?
    @user.is_member_or_admin? if @user
  end

  def update?
    is_admin?
  end


  def show?
    is_admin?
  end


  def new?
    create?
  end


  def create?
    is_admin?
  end

  def minutes_and_static_pages?
    index?
  end

end
