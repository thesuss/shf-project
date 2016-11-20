FactoryGirl.define do
  factory :membership_application do
    company_name 'MyString'
    company_number '5562252998'
    contact_person 'MyString'
    phone_number 'MyString'
    company_email 'MyString@email.com'
    association :user
  end
end
