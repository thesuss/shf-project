And(/^the following kommuns exist:$/) do |table|
  table.hashes.each do |kommun|
    FactoryBot.create(:kommun, kommun)
  end
end
