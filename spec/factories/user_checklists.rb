FactoryBot.define do

  factory :user_checklist do
    sequence(:name) { |n| "UserChecklist #{n}" }
    description { nil }
    user
    master_checklist
    date_completed { nil }
    list_position { 0 }

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
      num_children = evaluator.num_children == 0 ? evaluator.num_completed_children : evaluator.num_children

      not_completed_children = num_children - evaluator.num_completed_children
      # add child UserChecklist entries if num_children: is given in the call to this factory
      not_completed_children.times do |child_num|
        create(:user_checklist,
               user:user_checklist_entry.user, parent: user_checklist_entry,
               list_position: child_num)
      end

      # add completed child UserChecklist entries if num_completed_children: is given in the call to this factory
      evaluator.num_completed_children.times do |child_num|
        create(:user_checklist,
               :completed,
               user:user_checklist_entry.user, parent: user_checklist_entry,
               list_position: child_num + not_completed_children)
      end
    end

  end
end
