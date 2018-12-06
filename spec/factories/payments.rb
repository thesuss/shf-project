FactoryBot.define do

  factory :payment do
    user
    company { nil }
    payment_type { Payment::PAYMENT_TYPE_MEMBER }
    status { Payment.order_to_payment_status(nil) }
    start_date { Time.zone.today }
    expire_date { Time.zone.today + 1.year - 1.day }
    hips_id { 'none' }

    updated_at { Time.zone.now }
  end


  factory :membership_fee_payment, parent: :payment do
    payment_type { Payment::PAYMENT_TYPE_MEMBER }
  end

  factory :h_branding_fee_payment, parent: :payment do
    payment_type { Payment::PAYMENT_TYPE_BRANDING }
  end

  trait :successful do
    status { Payment::ORDER_PAYMENT_STATUS['successful'] }
  end

  trait :pending do
    status { Payment::ORDER_PAYMENT_STATUS['pending'] }
  end

  trait :expired do
    status { Payment::ORDER_PAYMENT_STATUS['expired'] }
  end

  trait :awaiting_payment do
    status { Payment::ORDER_PAYMENT_STATUS['awaiting_payments'] }
  end

end
