Given(/^I am on the landing page$/) do
  visit root_path
end

Given(/^I am on the list applications page$/) do
  visit memberships_path
end

Given(/^I am on "([^"]*)" application page$/) do |company_name|
  membership = MembershipApplication.find_by(company_name: company_name)
  visit membership_path(membership)
end