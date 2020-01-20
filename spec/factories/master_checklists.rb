FactoryBot.define do

  factory :master_checklist, class: AdminOnly::MasterChecklist do
    name { "MasterChecklist name" }
    displayed_text { "This is the text that would be displayed to a user." }
    description { "MasterChecklist description" }
    list_position { 0 }
    is_in_use { true }


    trait :not_in_use do
      is_in_use { false }
      is_in_use_changed_at { Time.zone.now }
    end


    # transient allows you to define and pass in variables that are not attributes of this model
    transient do
      num_children { 0 }
      parent_name { '' }
    end

    after(:create) do |checklist_master, evaluator|

      # add child ListEntries if num_children: is given in the call to this factory
      evaluator.num_children.times do |child_num|
        create(:master_checklist, parent: checklist_master, name: "child entry #{child_num}", list_position: child_num)
      end

      # try to look  up the parent if a parent_name was given in the call to this factory
      unless evaluator.parent_name.blank?
        parent = AdminOnly::MasterChecklist.find_by(name: evaluator.parent_name)
        checklist_master.update(parent: parent) if parent
      end
    end

  end

end
