module MembershipApplicationHelper

  def edit_status?
    policy(@membership_application).permitted_attributes_for_edit.include? :status
  end

end
