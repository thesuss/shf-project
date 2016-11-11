Given(/^I am on the landing page$/) do
  visit root_path
end

Given(/^I am on the list applications page$/) do
  visit memberships_path
end

Then(/^I should be on "([^"]*)" page$/) do |name|
  membership = MembershipApplication.find_by(company_name: name)
  expect(current_path).to eq membership_path(membership)
end
