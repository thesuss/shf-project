module AdminOnly

# An abstract super class for those classes that only Admins have permission to access
  class AdminOnlyPolicy < ApplicationPolicy


    def index?
      is_admin?
    end


    def update?
      is_admin?
    end


    def create?
      is_admin?
    end


    def new?
      create?
    end

  end

end
