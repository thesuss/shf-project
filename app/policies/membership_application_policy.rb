class MembershipApplicationPolicy < ApplicationPolicy

  def user_owner_attributes
    [:first_name,
     :last_name,
     :company_number,
     :contact_email,
     :phone_number,
     {business_category_ids: []}]
  end


  def attributes_and_status
    user_owner_attributes + [:status]
  end


  def permitted_attributes
    status_only_for_admin
  end

  def permitted_attributes_for_create
    attributes_and_status
  end

  def permitted_attributes_for_show
    user ? attributes_and_status : []
  end

  def permitted_attributes_for_edit
    status_only_for_admin
  end

  def permitted_attributes_for_update
    status_only_for_admin
  end

  def permitted_attributes_for_destroy
    status_only_for_admin
  end


  private

  def status_only_for_admin
    if user && user.admin?
      attributes_and_status
    else
      user_owner_attributes
    end
  end

end