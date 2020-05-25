FactoryBot.define do

  factory :user_checklist do

    name { 'UserChecklist name' }
    description { nil }
    association :user
    association :master_checklist
    date_completed { nil }
    list_position { 0 }


    factory :membership_ethical_guidelines do
      name { 'Ethical Guidelines' }
      description { 'SHF ethical guidelines applicant must agree to' }
      association :master_checklist, factory: :membership_guidelines_master_checklist
    end

    trait :completed do
      date_completed { Time.zone.now }
    end


    # transient allows you to define and pass in variables that are not attributes of this model
    transient do
      num_children { 0 }
      num_completed_children { 0 }
    end


    after(:build) do |user_checklist_entry, evaluator|

      # try to look  up the parent if a parent_id was given in the call to this factory
      unless evaluator.parent.blank?
        parent = UserChecklist.find(evaluator.parent.id)
        user_checklist_entry.update(parent: parent) if parent
      end
    end


    after(:create) do |user_checklist_entry, evaluator|

      # add completed child UserChecklist entries if num_completed_children: is given in the call to this factory
      evaluator.num_completed_children.times do |child_num|
        create(:user_checklist, :completed, user:user_checklist_entry.user, parent: user_checklist_entry, list_position: child_num)
      end

      # add child UserChecklist entries if num_children: is given in the call to this factory
      evaluator.num_children.times do |child_num|
        create(:user_checklist, user:user_checklist_entry.user, parent: user_checklist_entry, list_position: child_num)
      end

    end

  end

end
