And(/^the default data exists$/) do
  FactoryBot.create(:app_configuration)
end

And "the membership( chair) email is {capture_string}" do |email_addr|
  env_shf_membership_email_key = 'SHF_MEMBERSHIP_EMAIL'
  ENV[env_shf_membership_email_key] = email_addr
end
