When(/^I choose a shf-document named "([^"]*)" to upload$/) do | filename |
  page.attach_file "shf_document[actual_file]", File.join(Rails.root, 'spec', 'fixtures','uploaded_files', filename)
end


And(/^I should see (\d+) shf-documents listed$/) do |number|
  page.assert_selector('.shf-document', count: number)
end


Given(/^I am on the edit SHF document page for "([^"]*)"$/) do | doc_title |
  shf_doc = ShfDocument.find_by_title(doc_title)
  visit path_with_locale(edit_shf_document_path shf_doc)
end


Given(/^I am on the SHF document page for "([^"]*)"$/) do | doc_title |
  shf_doc = ShfDocument.find_by_title(doc_title)
  visit path_with_locale(shf_document_path shf_doc)
end
