FactoryGirl.define do
  factory :user do
    email 'email@random.com'
    password 'my_password'
    admin false
    is_member false
  end
end
