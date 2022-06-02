FactoryBot.define do
  factory :membership do
    owner { build(:user) }
    member_number { "1234 some number" }
    first_day { Time.zone.now - 11.months }
    last_day { Time.zone.now + 1.months - 1.day }
    notes { "This is a note about this particular membership that the admin might enter." }
  end
end
