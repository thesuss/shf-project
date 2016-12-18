Then(/^I should be on the landing page$/) do
  expect(current_path).to eq root_path
end


And(/^I should see "([^"]*)"$/) do |content|
  expect(page).to have_content content
end

And(/^I should not see "([^"]*)"$/) do |content|
  expect(page).not_to have_content content
end

And(/^I should not see "([^"]*)" image$/) do |alt_text|
  expect(page).not_to have_xpath("//img[contains(@alt,'#{alt_text}')]")
end

And(/^I should see "([^"]*)" image$/) do |alt_text|
  expect(page).to have_xpath("//img[contains(@alt,'#{alt_text}')]")
end

And(/^I should see t\("([^"]*)"\)$/) do |content|
  expect(page).to have_content i18n_content(content)
end

And(/^I should not see t\("([^"]*)"\)$/) do |content|
  expect(page).not_to have_content i18n_content(content)
end

And(/^I should see t\("([^"]*)", locale: :(.*)\)$/) do |content, l|
  expect(page).to have_content i18n_content(content, l)
end

And(/^I should not see t\("([^"]*)", locale: :(.*)\)$/) do |content, l|
  expect(page).not_to have_content i18n_content(content, l)
end

And(/^I should see t\("([^"]*)"\), locale: :sv$/) do |content|
  expect(page).to have_content i18n_content(content)
end

And(/^I should not see t\("([^"]*)"\), locale: :sv$/) do |content|
  expect(page).not_to have_content i18n_content(content)
end

And(/^I should see t\("([^"]*)", ([^:]*): ([^)]*)\), locale: :(.*)\)$/) do |content, key, value, l|
  expect(page).to have_content I18n.t("#{content}", key.to_sym => value, locale: l.to_sym)
end

And(/^I should not see t\("([^"]*)", ([^:]*): ([^)]*)\), locale: :(.*)\)$/) do |content, key, value, l|
  expect(page).not_to have_content I18n.t("#{content}", key.to_sym => value, locale: l.to_sym)
end

And(/^I should see t\("([^"]*)", ([^:]*): (\d+)\), locale: :(.*)$/) do |content, key, value, locale|
  expect(page).to have_content I18n.t("#{content}", key.to_sym => value, locale: locale.to_sym)
end

And(/^I should not see t\("([^"]*)", ([^:]*): (\d+)\), locale: :(.*)$/) do |content, key, value, locale|
  expect(page).not_to have_content I18n.t("#{content}", key.to_sym => value, locale: locale.to_sym)
end

And(/^I should see button "([^"]*)"$/) do |button|
  expect(page).to have_button button
end

And(/^I should not see button "([^"]*)"$/) do |button|
  expect(page).not_to have_button button
end

And(/^I should see button t\("([^"]*)"\)$/) do |button|
  expect(page).to have_button i18n_content(button)
end

And(/^I should not see button t\("([^"]*)"\)$/) do |button|
  expect(page).not_to have_button i18n_content(button)
end


And(/^I should see "([^"]*)" link$/) do |link_label|
  expect(page).to have_link link_label
end

And(/^I should see t\("([^"]*)"\) link$/) do |link_label|
  expect(page).to have_link i18n_content(link_label)
end

And(/^I should not see "([^"]*)" link$/) do |link_label|
  expect(page).not_to have_link link_label
end

And(/^I should not see t\("([^"]*)"\) link$/) do |link_label|
  expect(page).not_to have_link i18n_content(link_label)
end


Then(/^I should be on "([^"]*)" page$/) do |page|
  case page.downcase
    when  'login'
      path = new_user_session_path
    when 'landing'
      path = root_path
    when 'edit my application'
      path = edit_membership_application_path(@user.membership_applications.last)
    when 'show my application'
      path = membership_application_path(@user.membership_applications.last)
    when 'user instructions'
      path = information_path
    when 'member instructions'
      path = information_path
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

Then(/^I should be on the application page for "([^"]*)"$/) do |first_name|
  membership_application = MembershipApplication.find_by(first_name: first_name)
  expect(current_path).to eq membership_application_path(membership_application)
end

Then(/^I should be on the edit application page for "([^"]*)"$/) do |first_name|
  membership_application = MembershipApplication.find_by(first_name: first_name)
  expect(current_path).to eq edit_membership_application_path(membership_application)
end


Then(/^I should see "([^"]*)" applications$/) do |number|
  expect(page).to have_selector('.applicant', count: number)
end

Then(/^the field "([^"]*)" should have a required field indicator$/) do |label_text|
  expect(page.find('label', text: label_text)[:class].include?('required')).to be true
end

And(/^the field "([^"]*)" should not have a required field indicator$/) do |label_text|
  expect(page.find('label', text: label_text)[:class]).not_to have_css 'required'
end

Then(/^the field t\("([^"]*)"\) should have a required field indicator$/) do |label_text|
  expect(page.find('label', text: i18n_content(label_text))[:class].include?('required')).to be true
end

And(/^the field t\("([^"]*)"\) should not have a required field indicator$/) do |label_text|
  expect(page.find('label', text: i18n_content(label_text))[:class]).not_to have_css 'required'
end

Then(/^I should see (\d+) (.*?) rows$/) do |n, css_class_name|
  n = n.to_i
  expect(page).to have_selector(".#{css_class_name}", count: n)
  expect(page).not_to have_selector(".#{css_class_name}", count: n+1)
end


And(/^I should be on the applications page$/) do
  expect(current_path).to eq membership_applications_path
end

Then(/^I should see translated error (.*) (.*)$/) do |model_attribute, error|
  expect(page).to have_content("#{i18n_content(model_attribute)} #{i18n_content(error)}")
end
Then(/^I should see t\("([^"]*)", member_full_name: '([^']*)'\)$/) do |i18n_key, name_value|
 expect(page).to have_content(I18n.t(i18n_key, member_full_name: name_value))
end

And(/^I should see t\("([^"]*)", filename: '([^']*)'\)$/) do |i18n_key, filename_value|
  expect(page).to have_content(I18n.t(i18n_key, filename: filename_value))
end