module AdminOnly

  class AdminPageController < ApplicationController

    before_action :authorize_admin
    before_action :get_admin_page

    def edit
    end

    def update
      if @admin_page.update(admin_page_params)
        redirect_to root_path, notice: t('.success')
      else
        flash.now[:alert] = t('.error')
        render :edit
      end
    end

    private

    def authorize_admin
      AdminOnly::AdminPagePolicy.new(current_user).authorized?
    end

    def get_admin_page
      return @admin_page = AdminPage.last if AdminPage.any?

      @admin_page = AdminPage.new
    end

    def admin_page_params
      # Need to use "fetch" here (instead of "require") as thie form
      # currently contains only file_field(s), and if the user clicks
      # "Submit" without changing any of those fields (that is, without
      # specifying one or more files to upload, then those fields will
      # not be added to the params, and there will be no "admin_page"
      # key (for those fields) in the params).
      params.fetch(:admin_page, {}).permit(:chair_signature, :shf_logo)
    end
  end

end
