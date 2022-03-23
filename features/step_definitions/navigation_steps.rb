# Steps for navigating through the site: Visiting pages (I am on the "zzz" page),
# going to the next page, etc.
#


And("I am on the home page") do
  step %{I am on the "home" page}
end

And("I am on the landing page") do
  step %{I am on the "landing" page}
end



And("I should{negate} see a message telling me I am not allowed to see that page") do | negation |
  step %{I should#{negation} see t("errors.not_permitted")}
end


# Set the EU cookie consent cookie and then VISIT A PAGE
#
# Here are examples of strings that will match (the regular expression for) this step:
#   I am on the "blorf" page
#       page = 'blorf'
#       email = nil
#       eu_cookie_value = nil
#
#   I am on the "blorf" page for "x"
#       page = 'blorf'
#       email = 'x'
#       eu_cookie_value = nil
#
#   I am on the "blorf" page for "x" and the EU cookie is "z"
#       page = 'blorf'
#       email = 'x'
#       eu_cookie_value = 'z'
#
#   I am on the "blorf" page and the EU cookie is "z1"
#       page = 'blorf'
#       email = nil
#       eu_cookie_value = 'z'
#
# The default is to set the EU cookie consent cookie to 'true' so that
# the notice does NOT appear. If the notice does appear, it might block/cover
# elements that other steps are trying to work with.
#
Given(/^I am on the "([^"]*)" page(?: for "([^"]*)")?(?: and the EU cookie is "([^"]*)")?$/) do |page, email, eu_cookie_value|
  user = email == nil ? @user :  User.find_by(email: email)

  eu_cookie_value = eu_cookie_value.nil? ? 'true' : eu_cookie_value

  begin
    visit path_with_locale(get_path(page, user))
    step "the EU cookies consent cookie is set to \"#{eu_cookie_value}\""

  rescue ActionController::UrlGenerationError, ActionController::RoutingError => exception

    warn exception.message  # warn and then try to see if we can fix it by splitting at spaces

    begin
      path_components = page.split(/\s+/)
      # TODO refactor this code duplicated above (create a block/method with 'visit'() and 'step...')
      visit self.send(path_components.push('path').join('_').to_sym)
      step "the EU cookies consent cookie is set to \"#{eu_cookie_value}\""

    rescue NoMethodError, ArgumentError => error
      raise "exception: #{exception}\n" +
      "Tried to construct a path with the path components, but can't find mapping from \"#{page}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__} or assertion_steps.rb\n" +
          "original: #{error}\n"
    end

  rescue StandardError => orig_exception
    raise orig_exception  # a non-routing exception.  Shouldn't have happened if background data is correct and steps are written and called correctly
    end
  end


And("I should get a routing error when I try to visit the {capture_string} page") do | page |
  expect{visit path_with_locale(get_path(page, @user))}.to raise_error(ActionController::RoutingError)
end


And("I should get an error when I try to visit the {capture_string} page") do | page |
  expect{visit path_with_locale(get_path(page, @user))}.to raise_error
end


When(/^I fail to visit the "([^"]*)" page$/) do |page|
  path = get_path(page)
  visit path_with_locale(path)
  expect(current_path).not_to be path
end


When(/^I am on the static workgroups page$/) do
  visit page_path('yrkesrad')
end


When(/^I am on the test member page$/) do
  path = File.join(Rails.root, 'spec', 'fixtures',
                   'member_pages', 'testfile.html')

  allow_any_instance_of(ShfDocumentsController).to receive(:page_and_file_path)
    .and_return([ 'testfile', path ])

  visit contents_show_path('testfile')
end

Then(/^(?:I|they) click the browser back button and "([^"]*)" the prompt$/) do |modal_action|
  case modal_action
  when 'accept'  # accept == leave page
    page.accept_confirm { page.evaluate_script('window.history.back()') }

  when 'dismiss' # dismiss == stay on page
    page.dismiss_confirm { page.evaluate_script('window.history.back()') }

  else
    raise 'invalid modal_action specified'
  end
end

When(/^I am in (.*) browser$/) do |user_email|
  Capybara.session_name = user_email
  @user = User.find_by_email user_email
end

When(/^I reload the page$/) do
  visit current_path
end


When("I click on the pagination link to go to the next page") do
  step %{I click on t("will_paginate.next_label") link}
end
