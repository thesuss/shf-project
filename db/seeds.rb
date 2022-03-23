# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command
# (or created alongside the database with db:setup).

require 'ffaker'
require 'rake'

require 'activity_logger'
require 'logfile_namer'

require_relative 'seed_helpers'
require_relative 'require_all_seeders_and_helpers'

include SeedHelper

SEEDING_LOG_FILE_NAME = LogfileNamer.name_for('db:seed') unless defined?(SEEDING_LOG_FILE_NAME)
SEEDING_LOG_FACILITY = 'db:seed' unless defined?(SEEDING_LOG_FACILITY)

SEED_USERS = 30 unless defined?(SEED_USERS)

DEFAULT_PASSWORD = 'whatever' unless defined?(DEFAULT_PASSWORD)

# The test of defined? is due to the rspec file that executes the seed file
# repeatedly.  Without this, rspec complains about "already initialized constant"

MSG_SEED_COMPLETE = '<<< SEEDING COMPLETED' unless defined?(MSG_SEED_COMPLETE)
MSG_SEED_STOPPED = '<<< SEEDING STOPPED' unless defined?(MSG_SEED_STOPPED)
MSG_ERROR_RESCUED = "\n >>> ERROR RESCUED!" unless defined?(MSG_ERROR_RESCUED)
MSG_BE_PATIENT_ADDR_GEOCODING = "\n     If a company address must be created (instead of reading from a CSV file), it must be geocoded, which takes time.  Be patient." +
  "\n     You can look at the /log/development.log to be Seeure that things are happening and this is not stuck." +
  "\n     You can specify a CSV file of addresses to use in your .env file (.env.development etc.)." unless defined?(MSG_BE_PATIENT_ADDR_GEOCODING)

MSG_NO_APPCONFIG = 'No AppConfiguration seeded.  One already exists.' unless defined?(MSG_NO_APPCONFIG)
MSG_APPCONFIG_NEEDS_SITEMETAIMAGE = ' ... but there is no site meta image! You need to set one on the edit app configuration page (as an admin).' unless defined?(MSG_APPCONFIG_NEEDS_SITEMETAIMAGE)
# ----------------------------------------------------------------------------------------


def env_invalid_blank(env_key)
  env_val = nil
  raise SeedAdminENVError, SEED_ERROR_MSG if ENV[env_key].nil? || (env_val = ENV.fetch(env_key)).blank?
  env_val
end


def log_msg(severity, activity_msg, text)
  ActivityLogger.open(SEEDING_LOG_FILE_NAME, SEEDING_LOG_FACILITY, activity_msg) do |log|
    log.record(severity, text)
  end
end


def seed_model_with_seeder(model_klass, seeder, log_activity = model_klass.name)
  ActivityLogger.open(SEEDING_LOG_FILE_NAME, SEEDING_LOG_FACILITY, log_activity) do |log|
    if model_klass.exists?
      log.warn("#{seeder} table not empty.")
      log.info("#{model_klass} table contains #{model_klass.count} records.")
      log.warn("zero #{model_klass} objects created.")
    else
      seeder.seed
      log.info("Created #{model_klass.count} records.")
    end
  end
end



def log_totals_created(log)
  log.info('------------------------------------------------------------------------------')
  log.info("Users in the db: #{User.count}")
  log.info("  applicants:      #{User.not_a_member.count}")
  log.info("  current members: #{User.current_member.count}")
  log.info("  in grace period: #{User.in_grace_period.count}")
  log.info("  former members:  #{User.former_member.count}")

  log.info("Applications in the db: #{ShfApplication.count}")
  states = ShfApplication.aasm.states.map(&:name)
  states.sort.each do |state|
    log.info("  #{state}: #{ShfApplication.where(state: state).count }")
  end
end


# ----------------------------------------------------------------------------------------


begin
  log_msg('info', 'START', ">>> SEEDING ENVIRONMENT: #{Rails.env}")

  unless Rails.env.development? || Rails.env.production? ||
    Rails.env.test? || ENV['HEROKU_STAGING']

    log_msg('error', 'ERROR', 'Unknown Rails environment !!')
    log_msg('error', 'FINISHED', MSG_SEED_STOPPED)
    abort MSG_SEED_STOPPED
  end

  seed_model_with_seeder(Region, Seeders::RegionsSeeder)
  seed_model_with_seeder(Kommun, Seeders::KommunsSeeder)
  seed_model_with_seeder(AdminOnly::FileDeliveryMethod, Seeders::FileDeliveryMethodsSeeder)
  seed_model_with_seeder(BusinessCategory, Seeders::BusinessCategoriesSeeder)

  # init_generated_seeding_info

  static_data = SeedHelpers::StaticDataFactory.new

  ActivityLogger.open(SEEDING_LOG_FILE_NAME, SEEDING_LOG_FACILITY, 'Admin User') do |log|
    log.info('Creating admin user')

    email = env_invalid_blank('SHF_ADMIN_EMAIL')
    pwd = env_invalid_blank('SHF_ADMIN_PWD')

    if Rails.env.production?
      begin
        User.create!(email: email, password: pwd, admin: true,
                     first_name: 'SHF', last_name: 'Admin')
      rescue => e
        log.error(e.inspect)
        log.error(MSG_SEED_STOPPED)
        raise e
      end
    else
      User.create(email: email, password: pwd, admin: true,
                  first_name: 'SHF', last_name: 'Admin')
    end

  end

  if Rails.env.development? || Rails.env.staging? || ENV['HEROKU_STAGING']

    # -----------------------------------------
    # Master and User checklists, AppConfiguration

    ActivityLogger.open(SEEDING_LOG_FILE_NAME, SEEDING_LOG_FACILITY, 'Applications') do |log|
      log.info('Creating Ethical guidelines checklists for each user...')

      Seeders::MasterChecklistTypesSeeder.seed
      Seeders::MasterChecklistsSeeder.seed

      # Seed the AppConfiguration
      #   MasterChecklists must be seeded first so that the Membership guidelines checklist exists
      if AdminOnly::AppConfiguration.count == 0
        log.info('Seeding AppConfiguration...')
        Seeders::AppConfigurationSeeder.seed
      else
        log.info(MSG_NO_APPCONFIG)
        log.info(MSG_APPCONFIG_NEEDS_SITEMETAIMAGE) unless AdminOnly::AppConfiguration.last.site_meta_image.exists?
      end

    end

    # -----------------------------------------
    # Users of all types:  users, applicants, members
    ActivityLogger.open(SEEDING_LOG_FILE_NAME, SEEDING_LOG_FACILITY, 'Users') do |log|
      number_of_random_users_and_members = (ENV['SHF_SEED_USERS'] || SEED_USERS).to_i

      # The admin has already been created.  That counts as 1 User
      SeedHelpers::UsersFactory.new(static_data, log).seed_users_and_members(number_of_random_users_and_members - 1)
      log_totals_created(log)
    end
  end

  log_msg('info', 'FINISH', MSG_SEED_COMPLETE)

rescue => error

  ActivityLogger.open(SEEDING_LOG_FILE_NAME, SEEDING_LOG_FACILITY, 'ERROR') do |log|
    log.error(MSG_ERROR_RESCUED)
    log.error(error.message)
    log.info(MSG_SEED_STOPPED)
  end

  # Use 'puts' here in case there was a problem writing to the log.
  puts MSG_ERROR_RESCUED
  puts error.message
  puts MSG_SEED_STOPPED

  raise error
end
