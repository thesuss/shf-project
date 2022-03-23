FactoryBot.define do

  factory :address do

    street_address { 'Hundvägen 101' }
    post_code { '310 40' }
    city { 'Harplinge' }
    country { 'Sverige' }
    visibility { 'street_address' }
    #latitude  { 59.3251172 }
    #longitude { 18.0710935 }

    association :region, factory: :region, strategy: :build

    association :kommun, factory: :kommun, strategy: :build

    factory :company_address do
      association :addressable, factory: :company
    end


  end
end
