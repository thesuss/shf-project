# Steps for UploadedFiles

def upload_file_named(user, file_name, calling_step: 'unknown',
                      upload_date: Date.current,
                      description: '')
  file_already_uploaded = UploadedFile.find_by(user: user, actual_file_file_name: file_name)
  uploaded_file = if file_already_uploaded
                    file_already_uploaded.update!(description: description)
                    file_already_uploaded
                  else
                    if file_fixture_exists?(file_name, calling_step)
                      File.open(Rails.root.join(UPLOADED_FILES_DIR, file_name), 'r') do |f|
                        new_upload = UploadedFile.create!(user: user,
                                                          description: description,
                                                          actual_file: f,
                                                          actual_file_file_name: file_name)
                        new_upload
                      end
                    end
                  end
  uploaded_file.update(User.most_recent_upload_method => upload_date)
end


And(/^these files have been uploaded:?/) do |table|
  # If the UploadedFile does not already exist, create it.  (It will not be associaed with any application.)
  # If it does exist, set the description

  # | user_email | file name | date_uploaded | description |
  table.hashes.each do |hash|

    user = User.find_by(email: hash['user_email'].downcase)
    uploaded_file_name = hash['file name']
    description = hash['description']
    date_uploaded = hash.key?('date_uploaded') ? Date.parse(hash['date_uploaded']) : Date.current

    upload_file_named(user, uploaded_file_name, calling_step: 'these files have been uploaded:',
                      upload_date:date_uploaded, description: description)
  end
end

And "I uploaded a file named {capture_string} today" do |file_name|
  upload_file_named(@user, file_name, calling_step: 'I uploaded a file named {capture_string} today',
                    upload_date: Date.current)
end

# Find a string or not in the uploaded_files table
# (= the list of uploaded files on the #index page
And "I should{negate} see {capture_string} in the list of uploaded files" do |negated, expected_string|
  step %{I should#{negated ? ' not' : ''} see "#{expected_string}" in the div with id "uploaded-files-list"}
end

