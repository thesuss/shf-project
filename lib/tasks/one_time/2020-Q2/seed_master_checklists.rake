namespace :shf do
  namespace :one_time do

    desc 'Seed data for Master Checklists (and types)'
    task seed_master_checklists: :environment do |this_task|

      required_subdirs = %w(seeders)
      required_subdirs.each do |required_subdir|
        Dir[File.join(Rails.root, 'db', required_subdir, '**', '*.rb')].each do |file|
          require file
        end
      end

      full_task_name = this_task.to_s
      task_name = full_task_name.split(':').last # the task name without the namespace(s)

      ActivityLogger.open(LogfileNamer.name_for(task_name), 'OneTimeRakeTask', task_name) do |log|

        log.info("Seeding the data for MasterChecklists and MasterChecklistTypes.")

        # -----------------------------------------
        # Master ChecklistTypes

        begin
          items_seeded = Seeders::MasterChecklistTypesSeeder.seed(log: log)
          log.info("Seeding data for MasterChecklistTypes successful and complete. #{items_seeded.size} seeded.")

        rescue => error
          error_message = ">> ERROR! Could not seed MasterChecklistTypes: #{error}"
          log.error error_message
          raise error, error_message
        end

        begin
          items_seeded = Seeders::MasterChecklistsSeeder.seed(log: log)
          log.info("Seeding data for MasterChecklists successful and complete. #{items_seeded.size} seeded.")

        rescue => error
          error_message = ">> ERROR! Could not seed MasterChecklists: #{error}"
          log.error error_message
          raise error, error_message
        end

        log.info("Seeding data for MasterChecklists and -Types successful and complete.")

      end

    end

  end
end
