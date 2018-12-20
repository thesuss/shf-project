namespace :shf do
  desc 'load conditions to DB'
  task :load_conditions => [:environment] do
    # Start from scratch
    Condition.delete_all

    Condition.create(class_name: 'MembershipExpireAlert',
                     timing: 'before',
                     config: { days: [60, 30, 14, 2] })
  end
end
