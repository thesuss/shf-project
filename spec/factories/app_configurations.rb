FactoryBot.define do

  factory :app_configuration, class: AdminOnly::AppConfiguration do

    chair_signature do
      File.new("#{Rails.root}/spec/fixtures/app_configuration/chair_signature.png")
    end

    shf_logo do
      File.new("#{Rails.root}/spec/fixtures/app_configuration/shf_logo.png")
    end

    h_brand_logo do
      File.new("#{Rails.root}/spec/fixtures/app_configuration/h_brand_logo.png")
    end

    sweden_dog_trainers do
      File.new("#{Rails.root}/spec/fixtures/app_configuration/sweden_dog_trainers.png")
    end
  end
end
