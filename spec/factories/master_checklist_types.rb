FactoryBot.define do

  sequence(:name) { |num| "Master Checklist Type #{num}" }


  factory :master_checklist_type, class: 'AdminOnly::MasterChecklistType' do
    # name is created by the sequence above
    name
    description { 'description' }


    factory :membership_guidelines_master_checklist_type, class: 'AdminOnly::MasterChecklistType' do
      name { AdminOnly::MasterChecklistType.membership_guidelines_type_name }
      description { 'Membership Guidelines master checklist type description' }
    end

  end
end
