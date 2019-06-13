require 'active_support/logger'

namespace :shf do

  desc 'process conditions'
  task process_conditions: [:environment] do

    def process_klass(klass, condition, log)
      if klass
        klass.condition_response(condition, log)
      else
        raise 'klass is nil in task shf:process_conditions'
      end
    end


    use_slack_notification = true

    ActivityLogger.open(LogfileNamer.name_for(Condition), 'SHF_TASK', 'Conditions') do |log|

      class_name = nil
      klass = nil

      Condition.order(:class_name).each do |condition|

        unless condition.class_name == class_name
          class_name = condition.class_name
          klass = class_name.constantize
        end

        log.info("#{class_name} ...")

        if use_slack_notification
          SHFNotifySlack.notify_after(class_name) do
            process_klass(klass, condition, log)
          end
        else
          process_klass(klass, condition, log)
        end

      # If the problem is because of Slack Notification .... log it and continue.
      # Do not let it stop the processing.
      rescue Slack::Notifier::APIError => slack_error
        use_slack_notification = false
        log.error("Slack::Notifier::APIError Exception: #{slack_error.inspect}")
        log.error('Slack Notifications turned off! Condition processing continuing without it.')
        log.error('Retrying the previous condition...')
        retry

      # .... Otherwise, an exception was raised during condition processing -
      #      log the error and continue with condition processing.
      #      (If Slack connection is up, we'll have already notified via that).
      rescue StandardError => e
        log.error("Class: #{class_name}")
        log.error("Exception: #{e}:  #{e.inspect}")
        next
      end
    end
  end
end
