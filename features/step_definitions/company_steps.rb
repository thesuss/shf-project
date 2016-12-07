And(/^the following companies exist:$/) do |table|
  table.hashes.each do |company|
    FactoryGirl.create(:company, company)
  end
end

And(/^I am the page for company number "([^"]*)"$/) do |company_number|
  company = Company.find_by_company_number(company_number)
  visit company_path company
end

When(/^I am on the edit company page for "([^"]*)"$/) do |company_number|
  company = Company.find_by_company_number(company_number)
  visit edit_company_path company
end

Then(/^I can go to the company page for "([^"]*)"$/) do |company_number|
  company = Company.find_by_company_number(company_number)
  visit edit_company_path company
  expect(current_path).to eq edit_company_path(company)
end