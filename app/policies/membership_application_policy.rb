class MembershipApplicationPolicy < ApplicationPolicy

  def user_owner_attributes
    [:first_name,
     :last_name,
     :company_number,
     :contact_email,
     :phone_number,
     {business_category_ids: []},
     :uploaded_files,
     uploaded_files_attributes: [:id,
                                :actual_file,
                                :actual_file_file_name,
                                :actual_file_file_size,
                                :actual_file_content_type,
                                :actual_file_updated_at,
                                :_destroy]
    ]
  end


  def admin_attributes
    user_owner_attributes + [:status, :membership_number]
  end


  def permitted_attributes
    only_for_admin
  end

  def permitted_attributes_for_create
    admin_attributes
  end

  def permitted_attributes_for_show
    user ? admin_attributes : []
  end

  def permitted_attributes_for_edit
    only_for_admin
  end

  def permitted_attributes_for_update
    only_for_admin
  end

  def permitted_attributes_for_destroy
    only_for_admin
  end


  def new?
    is_admin?
  end


  def create?
    new?
  end


  private

  def only_for_admin
    if user && user.admin?
      admin_attributes
    else
      user_owner_attributes
    end
  end

end