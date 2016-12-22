class PagePolicy < Struct.new(:user, :record)

  def destroy?
    is_admin?
  end

  def show?
    user_is_member?
  end


  def index?
    user_is_member?
  end


  def new?
    is_admin?
  end


  def create?
    new?
  end


  def update?
    is_admin?
  end


  def edit?
    update?
  end


  private
  def user_is_member?
    (user.is_member? || user.admin?) if user
  end

  def is_admin?
    user.admin? if user
  end
end