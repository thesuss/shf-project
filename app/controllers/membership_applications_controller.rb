class MembershipApplicationsController < ApplicationController
before_action :get_membership_application, only: [:show, :edit, :update]
before_action :authorize_membership_application, only: [:show, :edit]
  def new
    @membership_application = MembershipApplication.new
  end

  def create
    @membership_application = current_user.membership_applications.new(membership_application_params)
    if @membership_application.save
      flash[:notice] = 'Thank you, Your application has been submitted'
      redirect_to root_path
    else
      render :new
    end
  end

  def index
    authorize MembershipApplication
    @membership_applications = MembershipApplication.all
  end

  def show

  end

  def edit

  end

  def update
    if @membership_application.update(membership_application_params)
      flash[:notice] = 'Membership Application
                        successfully updated'
    else
      flash[:alert] = 'A problem prevented the membership
                       application to be saved'
    end
    redirect_to edit_membership_application_path(@membership_application)
  end

  def update_status
    @membership_application = MembershipApplication.find(params[:membership_application_id])
    @membership_application.update(membership_application_params)
    flash[:notice] = 'Membership Application
                      successfully updated'
    redirect_back(fallback_location: membership_applications_path)
  end

  private
  def membership_application_params
    params.require(:membership_application).permit(:company_name,
                                                   :company_number,
                                                   :contact_person,
                                                   :company_email,
                                                   :phone_number,
                                                   :status)
  end

  def get_membership_application
    @membership_application = MembershipApplication.find(params[:id])
  end

  def authorize_membership_application
    authorize @membership_application
  end
end
