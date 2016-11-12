Given(/^I am on the landing page$/) do
  visit root_path
end

Given(/^I go to "([^"]*)" page for "([^"]*)"$/) do |page, email|
  binding.pry
  user = User.find_by(email: email)
  case page.downcase
    when 'edit my application'
      path = edit_membership_path(user.membership_applications.last)
  end
  visit path
end
