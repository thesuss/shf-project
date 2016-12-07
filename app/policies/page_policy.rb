class PagePolicy < Struct.new(:user, :record)


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

  def destroy?
    is_admin?
  end

  private
  def user_logged_in?
    !user.nil?
  end

  def user_is_member?
    (user.is_member || is_admin?) if user
  end

  def is_admin?
    user.admin? if user
  end
end