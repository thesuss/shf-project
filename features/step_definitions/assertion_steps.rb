Then(/^I should be on the landing page$/) do
  expect(current_path).to eq root_path
end

And(/^I should see "([^"]*)"$/) do |content|
  expect(page).to have_content content
end


Then(/^I should be on "([^"]*)" page$/) do |page|
  case page.downcase
    when 'edit my application'
      path = edit_membership_application_path(@user.membership_applications.last)
  end
  expect(current_path).to eq path
end


Then(/^I should see:$/) do |table|
  table.hashes.each do |hash|
    expect(page).to have_content hash[:content]
  end
end

And(/^"([^"]*)" should be set in "([^"]*)"$/) do |status, list|
  dropdown = page.find("##{list}")
  selected_option = dropdown.find('option[selected]').text
  expect(selected_option).to eql status
end

Then(/^I should be on the application page for "([^"]*)"$/) do |company_name|
  membership_application = MembershipApplication.find_by(company_name: company_name)
  expect(current_path).to eq membership_application_path(membership_application)
end

Then(/^I should see "([^"]*)" applications$/) do |number|
  expect(page).to have_selector('.companies', count: number)
end


Then(/^I should see "([^"]*)" by all required fields$/) do |star|
  expect('.req').to have_content(star)
end