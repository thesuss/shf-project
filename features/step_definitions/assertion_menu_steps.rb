
menu_items = [{test_name: 'home', content: 'Hem'},
              {test_name: 'log in', content: 'Logga in'},
              {test_name: 'log out', content: 'Logga ut'},
              {test_name: 'brochures and info', content: 'Broschyr'},
              {test_name: 'member application', content: 'Ansök om medlemsskap'},
              {test_name: 'edit my application', content: 'Min ansökan'},
              {test_name: 'edit my company', content: 'Redigera företag'},
              {test_name: 'member only pages', content: 'Medlemssidor'},
              {test_name: 'admin', content: 'Hantera ansökningar'}
]

Then(/^I should ([not ]*)see the "([^"]*)" menu item$/) do |should_not, menu|
  should_have_it = should_not.blank?
  menu_item = menu_items.find { |m| m[:test_name] == menu.downcase }
  menu_item ? expect_page_has(menu_item[:content], should_have_it) : false
end

def expect_page_has(content, expect_to_match)
  expect_to_match ? (expect(page).to have_content(content)) : (expect(page).not_to have_content(content))
end
