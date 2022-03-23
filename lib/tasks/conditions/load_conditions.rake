namespace :shf do
  desc 'delete all Conditions and then call load_conditions task'
  task delete_and_reload_conditions: [:environment] do
    connection = ActiveRecord::Base.connection
    connection.exec_query("TRUNCATE TABLE \"conditions\" ")

    Rake::Task['shf:load_conditions'].invoke
  end

  desc 'load conditions to DB'
  task load_conditions: [:environment] do

    # Schedules for when alerts are sent:
    std_reminder_after_schedule = [2, 9, 14, 30, 60]
    std_reminder_before_schedule = [60, 30, 14, 2]

    # See the ConditionResponder class for defintions of the different possible
    # timing methods and configurations.


    # NUMBER OF DAYS TO KEEP BACKUPS ON THE PRODUCTION SERVER:
    # -------------------------------------------------------
    # 8 days is the default because: if there is a problem (e.g. coping to AWS)
    #  and we don't spot it for a week
    #  (perhaps we didn't have a weekly meeting on a Thursday), the backup files still exist on the production server.
    DEFAULT_DAYS_TO_KEEP = 4

    # Code also exists on GitHub and in a the version control system (git). [In fact, those
    #   are the authoritative/canonical source. ] So we don't need to keep very many days of backups.
    DAYS_TO_KEEP_CODE = 3

    DAYS_TO_KEEP_PUBLIC_FILES = DEFAULT_DAYS_TO_KEEP


    # Filesystem locations
    RUNNING_LOG = '~/NOTES-RUNNING-LOG.txt'
    NGINX_LOG_DIR = '/var/log/nginx'
    APP_DIR = File.join(ENV['SHF_APP_PATH'], 'current/')
    PUBLIC_DIR = File.join(APP_DIR, 'public')

    # exclude File.join('**','development_paperclip_files', 'uploaded_files','*')
    # Exclude all user uploaded files in the paperclip directory
    # paperclip path (url) for the uploaded files =  Rails.application.config.paperclip_defaults[:url]
    # Get the path up to the first ':' (':' are use for interpolation by paperclip; ':' signals a variable value to be used)
    #  the path up to the first ':' will be the parent directory
    paperclip_uploads_path_top = Rails.application.config.paperclip_defaults[:url].split(':').first
    uploaded_files_exclude_path = "**#{File.join(paperclip_uploads_path_top, 'uploaded_files/')}*"

    # Add a Hash for each Condition to be created
    #
    conditions_to_create = [

        # Send this alert once a week on Tuesday ( = weekday #2 as defined in the Date class)
        { class_name: 'MembersNeedPacketsAlert',
            timing:     :day_of_week,
            config:     { days_of_week: [2]} },

        # # Once Repeating Task timing is implemented, the timing should be changed
        # # to repeat every 14 days.
        # { class_name: 'MemberUnpaidOver6MonthsAlert',
        #   timing:     :day_of_month,
        #   config: {days: [1, 15]} },
        #
        # { class_name: 'MembershipExpireAlert',
        #   timing:     :before,
        #   config:     { days: [30, 14, 2] } },
        #
        # { class_name: 'MembershipWillExpireRenewalReqsAlert',
        #   timing:     :before,
        #   config:     { days: [60] } },
        #
        #
        # { class_name: 'MembershipLapsedAlert',
        #   timing:     :after,
        #   config:     { days: std_reminder_after_schedule } },
        #
        # { class_name: 'FirstMembershipFeeOwedAlert',
        #   timing:     :after,
        #   config:     { days: std_reminder_after_schedule } },
        #
        # { class_name: 'HBrandingFeeWillExpireAlert',
        #   timing:     :before,
        #   config:     { days: std_reminder_before_schedule } },
        #
        # { class_name: 'HBrandingFeeDueAlert',
        #   timing:     :after,
        #   config:     { days: std_reminder_after_schedule } },

        { class_name: 'CompanyInfoIncompleteAlert',
          timing:     :after,
          config:     { days: std_reminder_after_schedule } },

        { class_name: 'ShfAppNoUploadedFilesAlert',
          timing:     :after,
          config:     { days: [60, 30, 14, 9, 2] } },


        # days_to_keep - specifies number of (daily) backups to retain on production server
        # backup_directory - where daily backups are retained on production server;
        #                    omit or set to nil to use default directory
        #
        { class_name: 'Backup',
          timing:     :every_day,
          config:     { days_to_keep:     { code_backup: DAYS_TO_KEEP_CODE,
                                            db_backup:   DEFAULT_DAYS_TO_KEEP },
                        backup_directory: nil,
                        filesets: [
                            {name: 'logs',
                             days_to_keep: DEFAULT_DAYS_TO_KEEP,
                             files: [RUNNING_LOG, NGINX_LOG_DIR, File.join(APP_DIR, 'log')]
                            },
                            {name: 'code',
                             days_to_keep: DAYS_TO_KEEP_CODE,
                             files: [APP_DIR],
                             excludes: ['public', 'docs', 'features', 'spec','tmp', '.yardoc']
                            },
                            {name: 'app-public',
                             days_to_keep: DAYS_TO_KEEP_PUBLIC_FILES,
                             files: [PUBLIC_DIR],
                             excludes: [uploaded_files_exclude_path]
                            },
                            {name: 'config env secrets',
                            days_to_keep: DEFAULT_DAYS_TO_KEEP,
                             files: [File.join(APP_DIR, 'config', '*.yml'), '.env']
                            }
                        ]
          }
        },

        { class_name: 'DinkursFetch',
          timing:     :every_day },

        { class_name: 'MembershipStatusCheck',
          timing:     :every_day }
    ]


    # Start from scratch
    Condition.delete_all

    if Condition.create(conditions_to_create)
      puts "  #{conditions_to_create.size} Conditions were loaded into the db: #{conditions_to_create.map{|h_cond| h_cond[:class_name]}.join(', ')}"
    end

  end
end
