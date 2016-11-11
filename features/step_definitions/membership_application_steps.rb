And(/^the following applications exist$/) do |table|
  table.hashes.each do |hash|
    user = User.find_by(email: hash[:user_email])
    FactoryGirl.create(:application, company_name: hash[:company_name], user: user)
  end
end