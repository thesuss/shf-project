class MemberPage < ApplicationRecord
  validates_presence_of :filename
  # Note that we are not checking for uniqueness of filename - this is because
  # all of the member page files are maintained in a single directory (accessed
  # by HighVoltage) and hence the OS will ensure unique filenames

  def self.title(file_name)
    member_page = find_or_create(file_name)

    return file_name.capitalize unless member_page.title

    member_page.title
  end

  private_class_method def self.find_or_create(file_name)
    member_page = find_by filename: file_name

    return member_page if member_page
    return MemberPage.create(filename: file_name)
  end
end
