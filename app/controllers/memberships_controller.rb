class MembershipsController < ApplicationController
  def new
    @membership = MembershipApplication.new
  end

  def create
    @membership = current_user.membership_applications.new(membership_params)
    if @membership.save
      flash[:notice] = 'Thank you, Your application has been submitted'
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    if is_current_user_application
    else
      flash[:alert] = "You are not authorized to view this page"
      redirect_to root_path
    end
  end

  def update

  end


  private
  def is_current_user_application
    @membership = current_user.membership_applications.find_by_id(params[:id])
  end
  def membership_params
    params.require(:membership_application).permit(:company_name,
                                                   :company_number,
                                                   :contact_person,
                                                   :company_email,
                                                   :phone_number)
  end
end
