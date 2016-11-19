class AdminController < ApplicationController
  before_action :get_membership_application, only: [:show_membership_application]

  def index
    redirect_to membership_applications_path
  end

  def show_membership_application
    redirect_to membership_application_path(@membership_application)
  end

  private
  def get_membership_application
    @membership_application = MembershipApplication.find(params[:id])
  end
end
