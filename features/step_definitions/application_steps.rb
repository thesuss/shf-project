Given(/^the following applications exist:$/) do |table|
  table.hashes.each do |application|
    MembershipApplication.create application
  end
end
