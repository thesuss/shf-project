class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    edit?
  end

  def index?
    @user.admin? if @user
  end

  def update?
    is_admin? ||  @record.user == @user
  end

  def edit?
    update?
  end


  def destroy?
    is_admin?
  end


  private

  def is_admin?
    @user.admin? if @user
  end

end
