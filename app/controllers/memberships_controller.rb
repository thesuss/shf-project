class MembershipsController < ApplicationController
  def new
    @membership = MembershipApplication.new
  end

  def create
    @membership = MembershipApplication.new(membership_params)
    if @membership.save
      flash[:notice] = 'Thank you, Your application has been submitted'
      redirect_to root_path
    else
      render :new
    end
  end

  def index
    @membership_applications = MembershipApplication.all
  end

  def show
    @membership = MembershipApplication.find(params[:id])
  end

  def update
    @membership = MembershipApplication.find(params[:id])
    if @membership.update(membership_params)
      flash[:notice] = 'Membership Application successfully updated'
      render :show
    else
      flash[:alert] = 'A problem prevented the membership application to be saved'
      render :show
    end
  end

  private
  def membership_params
    params.require(:membership_application).permit(:company_name,
                                                   :company_number,
                                                   :contact_person,
                                                   :company_email,
                                                   :phone_number,
                                                   :status)
  end
end
