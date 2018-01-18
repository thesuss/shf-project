FactoryGirl.define do

  factory :admin_page, class: AdminOnly::AdminPage do

    chair_signature do
      File.new("#{Rails.root}/spec/fixtures/admin_data/signature.png")
    end

    shf_logo do
      File.new("#{Rails.root}/spec/fixtures/admin_data/medlem.png")
    end
  end
end
