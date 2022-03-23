FactoryBot.define do

  factory :one_time_tasker_task_attempt, class: OneTimeTasker::TaskAttempt do
    task_name { "task name" }
    task_source { "task source" }
    attempted_on { Time.zone.now }
    was_successful { false }
    notes { '' }
  end

  # cannot just use :successful because it collides with
  # the :successful trait used in the payments factory
  trait :successful_task do
    was_successful { true }
  end

  trait :unsuccessful_task do
    was_successful { false }
  end

end
