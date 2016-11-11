Then(/^I should be on the landing page$/) do
  expect(current_path).to eq root_path
end

And(/^I should see "([^"]*)"$/) do |content|
  expect(page).to have_content content
end


Then(/^I should be on "([^"]*)" page$/) do |page|
  case page.downcase
    when 'edit my application'
      path = edit_membership_path(@user.membership_applications.last)
  end

  expect(current_path).to eq path
end

