namespace :shf do
  namespace :one_time do

    desc "Create initial AppConfiguration instance"
    task create_app_config: :environment do

      log_file = 'log/create_app_config'

      ActivityLogger.open(log_file, 'AppConfiguration', 'create') do |log|

        log.record('info', 'Checking whether AppConfiguration exists ...')

        if AdminOnly::AppConfiguration.count == 0
          log.record('info', 'DOES NOT exist - creating.')
          AdminOnly::AppConfiguration.create
        else
          log.record('info', 'DOES exist - exiting.')
        end
      end
    end
  end
end
