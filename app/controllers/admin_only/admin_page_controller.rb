module AdminOnly

  class AdminPageController < ApplicationController
    before_action :authorize_admin

    def show
    end

    def edit
    end

    def update
    end

    private

    def authorize_admin
      AdminPolicy.new(current_user).authorized?
    end
  end

end
