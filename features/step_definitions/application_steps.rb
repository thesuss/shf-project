Given(/^the following applications exist:$/) do |table|
  table.hashes.each do |application|
    FactoryGirl.create(:membership_application, application)
  end
end

Then(/^I should see "([^"]*)" applications$/) do |number|
  expect(page).to have_selector('.companies', count: number)
end


When(/^I set "([^"]*)" to "([^"]*)"$/) do |list, status|
  page.select status, from: list
end

And(/^"([^"]*)" should be set in "([^"]*)"$/) do |status, list|
  dropdown = page.find("##{list}")
  selected_option = dropdown.find(:xpath, 'option[1]').text
  expect(selected_option).to eql status
end