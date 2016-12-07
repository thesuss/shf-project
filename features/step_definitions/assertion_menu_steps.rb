home_menu_name = 'home'
log_in_menu_name = 'log in'
log_out_menu_name = 'log out'
brochure_menu_name = 'brochures and info'
member_application_menu_name = 'member application'
member_only_pages_menu_name = 'member only pages'
admin_menu_name = 'admin'

home_menu_content = 'Hem'
log_in_menu_content = 'Logga in'
log_out_menu_content = 'Logga ut'
brochure_menu_content = 'Broschyr'
member_application_menu_content = 'Ansök om medlemsskap'
member_only_pages_content = 'Medlemssidor'
admin_menu_content = 'Hantera ansökningar'


Then(/^I should ([not ]*)see the "([^"]*)" menu$/) do | should_not , menu|
  should_have_it =  should_not.blank?

  case menu.downcase
    when home_menu_name
      expect_page_has home_menu_content, should_have_it
    when log_in_menu_name
      expect_page_has log_in_menu_content, should_have_it
    when brochure_menu_name
      expect_page_has brochure_menu_content, should_have_it
    when member_application_menu_name
      expect_page_has member_application_menu_content, should_have_it
    when member_only_pages_menu_name
      expect_page_has member_only_pages_content, should_have_it
    when admin_menu_name
      expect_page_has admin_menu_content, should_have_it
  end

end

def expect_page_has(content, expect_to_match)
  expect_to_match ? (expect(page).to have_content(content)) : (expect(page).not_to have_content(content))
end
