module ApplicationHelper
  def flash_class(level)
    case level.to_sym
      when :notice then 'success'
      when :alert then 'danger'
    end
  end

  def flash_message(type, text)
    flash[type] ||= []
    if flash[type].instance_of? String
      flash[type] = [flash[type]]
    end
    flash[type] << text
  end

  def render_flash_message(flash_value)
    if flash_value.instance_of? String
      flash_value
    else
      safe_join(flash_value, '<br/>'.html_safe)
    end
  end

  def user_has_membership_application?
    current_user.try(:membership_applications).try(:any?) && current_user.try(:membership_applications).try(:last).try(:persisted?)
  end

  def member_has_company?
    current_user.is_member && !current_user.membership_applications.last.company.nil?
  end
end
