module MembershipApplicationsHelper

  def can_edit_state?
    policy(@membership_application).permitted_attributes_for_edit.include? :state
  end

  def member_full_name
    @membership_application ? "#{@membership_application.first_name} #{@membership_application.last_name}" : '..'

  end
end
