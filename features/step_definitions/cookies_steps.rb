# Steps dealing with cookies
#
# This uses the ShowMeTheCookies gem to show, set, delete cookies.
# That gem handles the different possible drivers.
#
# You can display the current cookies with
#   puts "show_me_cookies_adapter.get_me_the_cookies: #{@show_me_cookies_adapter.get_me_the_cookies}"

EU_COOKIE_NAME = 'cookie_eu_consented'

# -----------------------
# EU cookies consent (see the cookies_eu gem)
#
And("the EU cookies consent cookie is set to {capture_string}") do | cookie_value|
  curr_driver = Capybara.current_driver
  curr_session_driver = Capybara.current_session.driver
  show_me_cookies_adapter = ShowMeTheCookies.adapters[curr_driver].new(curr_session_driver)

  show_me_cookies_adapter.create_cookie(EU_COOKIE_NAME, cookie_value, {})
end

And("the EU cookies consent cookie is set to true") do
  step 'the EU cookies consent cookie is set to "true"'
end

And("the EU cookies consent cookie is set to false") do
  step 'the EU cookies consent cookie is set to "false"'
end

And("the EU cookies consent cookie does not exist") do

  curr_driver = Capybara.current_driver
  curr_session_driver = Capybara.current_session.driver
  show_me_cookies_adapter = ShowMeTheCookies.adapters[curr_driver].new(curr_session_driver)

  show_me_cookies_adapter.delete_cookie(EU_COOKIE_NAME)
end
