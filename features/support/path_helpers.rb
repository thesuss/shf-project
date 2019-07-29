
#
# @module PathHelpers
#
# @description Methods for constructing a path to visit.  Deals with locale
# in the path, has a list of all known page names (in the get_path() case statement),
# and can construct a 'manual' path if needed.
#
module PathHelpers

  # remove any leading locale path info
  def current_path_without_locale(path)
    locale_pattern =  /^(\/)(en|sv)?(\/)?(.*)$/
    path.gsub(locale_pattern, '\1\4')
  end


  # All known paths.  Based on the page name, visit the appropriate page.
  # If the pagename is not in this list, then try to 'manually' construct it.
  #
  # @return [String] - the path to visit
  def get_path(pagename, user = @user)

    case pagename.downcase
      when  'login'
        path = new_user_session_path
      when 'landing'
        path = root_path
      when 'new application'
        path = new_shf_application_path
      when 'edit application', 'edit my application'
        user.reload
        path = edit_shf_application_path(user.shf_application)
      when 'application', 'show my application'
        path = shf_application_path(user.shf_application)
      when 'user instructions'
        path = information_path
      when 'member instructions'
        path = information_path
      when 'all waiting for info reasons'
        path = admin_only_member_app_waiting_reasons_path
      when 'new waiting for info reason'
        path = new_admin_only_member_app_waiting_reason_path
      when 'register as a new user'
        path = new_user_registration_path
      when 'edit registration for a user'
        path = edit_user_registration_path
      when 'new password'
        path = new_user_password_path
      when 'all member app waiting reasons'
        path = admin_only_member_app_waiting_reasons_path
      when 'business categories'
        path = business_categories_path
      when 'membership applications', 'shf applications'
        path = shf_applications_path
      when 'all companies'
        path = companies_path
      when 'create a new company'
        path = new_company_path
      when 'submit new membership application'
        path = new_shf_application_path
      when 'my first company'
        path = company_path(user.shf_application.companies.first)
      when 'my second company'
        path = company_path(user.shf_application.companies.second)
      when 'my third company'
        path = company_path(user.shf_application.companies.third)
      when 'edit my company'
        path = edit_company_path(user.shf_application.companies.first)
      when 'all users'
        path = users_path
      when 'all shf documents'
        path = shf_documents_path
      when 'new shf document'
        path = new_shf_document_path
      when 'user details', 'user profile'
        path = user_path(user)
      when 'test exception notifications'
        path = test_exception_notifications_path
      when 'admin dashboard'
        path = admin_only_dashboard_path
      when 'admin edit app configuration'
        path = admin_only_edit_app_configuration_path
      when 'admin show app configuration'
        path = admin_only_app_configuration_path
      when 'cookies'
        path = cookies_path

      else
        raise PagenameUnknown.new(page_name: pagename)
    end

    path
  end


  # Manually construct a path to visit,
  # adding 'path' to the end and replacing spaces with underscores
  def create_manually_underscored_path(pagename)
    path_components = pagename.split(/\s+/)
    path_components.push('path').join('_')
  end

end
# --------------------------------------------------
