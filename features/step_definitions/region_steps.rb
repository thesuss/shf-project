And(/^the following regions exist:$/) do |table|
  table.hashes.each do |region|
    FactoryBot.create(:region, region)
  end
end

And(/^the name for region "([^"]*)" is changed to "([^"]*)"$/) do | old_name, new_name |
  region = Region.find_by_name(old_name)
  region.name = new_name
  region.save!  # do not do validations in case we're putting this into a bad state on purpose
end
