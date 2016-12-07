module MembershipApplicationsHelper

  def edit_status?
    policy(@membership_application).permitted_attributes_for_edit.include? :status
  end

  def member_full_name
    @membership_application ? "#{@membership_application.first_name} #{@membership_application.last_name}" : '..'

  end
end
