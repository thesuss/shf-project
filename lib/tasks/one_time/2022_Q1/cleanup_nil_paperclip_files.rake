require 'active_support/logger'

namespace :shf do

  namespace :one_time do

    desc 'rake task that removes all nil Paperclip file objects'
    task :cleanup_nil_paperclip_files => :environment do |this_task|

      task_name = this_task.to_s.split(':').last # the task name without the namespace(s)

      log_msg_starter = "Remove all 'nil' Paperclip file objects"

      ActivityLogger.open(LogfileNamer.name_for("SHF-one-time-task-#{task_name}"),
                          'OneTimeRakeTask', task_name) do |log|

        log.info(log_msg_starter)

        query = UploadedFile.where(actual_file_file_size: nil)

        log.info("Number of 'nil' uploaded files: #{query.count}")

        query.destroy_all

        log.info("\n#{log_msg_starter} successful and complete.")
      end
    end
  end
end
