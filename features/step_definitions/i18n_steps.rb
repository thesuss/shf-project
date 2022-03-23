And(/^I set the locale to "([^"]*)"$/) do | locale|
  I18n.locale = locale
end
