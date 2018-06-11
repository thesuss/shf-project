FactoryBot.define do
  factory :event do
    fee "9.99"
    start_date "2018-03-26"
    description "MyText"
    dinkurs_id 'abcxyz'
    name 'my test event'
    sign_up_url "MyString"

    association :company
  end
end
