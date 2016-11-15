Given(/^I am on the "([^"]*)" page$/) do |page|
  case page.downcase
    when 'landing'
      path = root_path
    when 'login'
      path = new_user_session_path
    when 'edit my application'
      path = edit_membership_application_path(@user.membership_applications.last)
    else
      path = 'no path set'
  end
  visit path
end

When(/^I try to visit the "([^"]*)" page$/) do |page|
  case page.downcase
    when 'applications index'
      path = membership_applications_path
    else
      path = 'path not set'
  end
  visit path
  expect(current_path).not_to be path
end
