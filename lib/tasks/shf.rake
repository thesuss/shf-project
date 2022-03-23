require 'active_support/logger'


namespace :shf do

  ACCEPTED_STATE = 'accepted' unless defined?(ACCEPTED_STATE)
  LOG_FILE       = 'log/shf_tasks.log' unless defined?(LOG_FILE)

  # TODO removed shf:dinkurs_load task once response condition (DinkursFetch) is deployed
  desc 'load Dinkurs events for companies'
  task :dinkurs_load => [:environment] do

    LOG = 'log/dinkurs_load_events.log'

    ActivityLogger.open(LOG, 'SHF_TASK', 'Load Dinkurs Events') do |log|

      Company.where.not(dinkurs_company_id: [nil, '']).order(:id).each do |company|

        company.fetch_dinkurs_events
        company.reload
        log.record('info', "Company #{company.id}: #{company.events.count} events.")

      end
    end
  end

  desc 'prepare db (current env): drop, setup, migrate, create baseline data.'
  task db_prep: [:environment] do

    Rake::Task['db:drop'].invoke if database_exists?

    tasks = ['db:create', 'db:migrate', 'db:test:prepare',
             'shf:load_regions', 'shf:load_kommuns',
             'shf:load_file_delivery_methods']

    tasks.each { |t| Rake::Task[t].invoke }

    puts "\n DB is created with baseline data.\n"
    puts "\n Be sure to run 'rails db:seed' if you need seed data. \n\n"
  end


  # @desc rails/rake task that runs cucumber using the 'shf_core_only' profile
  # (which is defined in config/cucumber.yml)
  #
  # @usage pass arguments from the command line as a string in an array:
  #     bundle exec rails shf:cuke_core_only['features/user_account']
  #       will run only the features in the features/user_account directory
  #     bundle exec rails shf:cuke_core_only['--format html features/user_account']
  #       will use the html format and run only the features in the features/user_account directory
  #
  desc "run Cucumber 'core' features only.Pass in other cucumber args as one string.(skip db_seeding, conditions, selenium_browser). [shf_core profile in config/cucumber.yml]"
  task :cuke_core_only, [:cucumber_args_as_a_string] => [:environment] do | _task, task_args |

    require 'cucumber/rake/task'

    usage = "\nshf:cuke_core_only runs the cucumber profile 'shf_core', which excludes 'non-core' and long-running features.\n shf_core is defined in config/cucumber.yml\n\n USAGE: rails shf:cuke_core_only['<any options for cucumber here>']\n    Ex: rails shf:cuke_core_only['--format html features/user_account']\n"

    t_args = task_args[:cucumber_args_as_a_string]

    if t_args == '--help' || t_args == '-H' || t_args == 'h'
      puts usage

    else
      Cucumber::Rake::Task.new('shf_core_only_cuke_task', 'Run only the SHF core features') do |cuke_t|
        cuke_t.cucumber_opts = t_args
        cuke_t.profile = 'shf_core'
      end

      Rake::Task[:shf_core_only_cuke_task].invoke
    end

  end


  desc "import membership apps from csv file. Provide the full filename (with path)"
  task :import_membership_apps, [:csv_filename] => [:environment] do |t, args|

    require 'csv'
    require 'smarter_csv'

    usage = 'rake shf:import_membership_apps["./spec/fixtures/test-import-files/member-companies-sanitized-small.csv"]'

    DEFAULT_PASSWORD = 'whatever'

    headers_to_columns_mapping = {
        membership_number: :membership_number,
        email:             :email,
        company_number:    :company_number,
        first_name:        :first_name,
        last_name:         :last_name,
        company_name:      :company_name,
        street:            :street,
        post_code:         :post_code,
        stad:              :city,
        region:            :region,
        phone_number:      :phone_number,
        website:           :website,
        category1:         :category1,
        category2:         :category2
    }

    csv_options = {
        col_sep:             ';',
        headers_in_file:     true,
        remove_empty_values: false,
        remove_zero_values:  false,
        file_encoding:       'UTF-8',
        key_mapping:         headers_to_columns_mapping
    }

    log = ActivityLogger.open(LOG_FILE, 'SHF_TASK', 'Import CSV')

    if args.has_key? :csv_filename

      if File.exist? args[:csv_filename]

        csv = SmarterCSV.process(args[:csv_filename], csv_options)
        #csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')

        num_read   = 0
        error_rows = 0
        csv.each do |row|
          begin
            import_a_member_app_csv(row, log)
            num_read += 1
          rescue ActiveRecord::RecordInvalid => invalid_info
            error_rows += 1
            log.record('error', "#{invalid_info.record.errors.full_messages.join(", ")}")
          end
        end

        msg = "\nRead #{num_read + error_rows} rows.\n" +
            "#{num_read} were valid and their information was imported.\n" +
            "#{error_rows} had errors."
        log.record('info', msg)

      else
        log.record('error', "#{args[:csv_filename]} does not exist. Nothing imported")
        log.close
        raise LoadError
      end

    else
      msg = "You must specify a .csv filename to import.\n  Ex: #{usage}"
      log.record('error', msg)
      log.close
      raise "ERROR: You must specify a .csv filename to import. Ex: #{usage}"
    end

    log.close
  end

  desc "load regions data (counties plus 'Sverige' and 'Online')"
  task :load_regions => [:environment] do

    # NOTE: This is now accomplished with the Seeder::RegionsSeeder

    ActivityLogger.open(LOG_FILE, 'SHF_TASK', 'Load Regions') do |log|

      # Populate the 'regions' table for Swedish regions (aka counties),
      # as well as 'Sverige' (Sweden) and 'Online'.  This is used to specify
      # the primary region in which a company operates.
      #
      # This uses the 'city-state' gem for a list of regions (name and ISO code).

      if Region.exists?
        log.record('warn', 'Regions table not empty.')
      else
        CS.states(:se).each_pair { |k, v| Region.create(name: v, code: k.to_s) }
        Region.create(name: 'Sverige', code: nil)
        Region.create(name: 'Online', code: nil)

        log.record('info', "#{Region.count} Regions created.")
      end
    end
  end

  desc "load kommuns data (290 Swedish municipalities)"
  task :load_kommuns => [:environment] do

    # NOTE: This is now accomplished with the Seeder::KommunsSeeder

    require 'csv'
    require 'smarter_csv'

    ActivityLogger.open(LOG_FILE, 'SHF_TASK', 'Load Kommuns') do |log|

      if Kommun.exists?
        log.record('warn', 'Kommuns table not empty.')
      else
        SmarterCSV.process('lib/seeds/kommuner.csv').each do |kommun|
          Kommun.create(name: kommun[:name])
        end

        log.record('info', "#{Kommun.count} Kommuns created.")
      end
    end
  end

  desc "Initialize app file delivery methods"
  task load_file_delivery_methods: :environment do

    # NOTE: This is now accomplished with the Seeder::FileDeliveryMethodsSeeder

    log_file = 'log/load_file_delivery_methods.log'

    ActivityLogger.open(log_file, 'App Files', 'set delivery methods') do |log|

      if AdminOnly::FileDeliveryMethod.exists?
        log.record('warn', 'FileDeliveryMethod table not empty.')
        next # break out of rake task
      end

      delivery_methods = [
          { name:           AdminOnly::FileDeliveryMethod::METHOD_NAMES[:upload_now],
            description_sv: 'Ladda upp nu',
            description_en: 'Upload now',
            default_option: true },

          { name:           AdminOnly::FileDeliveryMethod::METHOD_NAMES[:upload_later],
            description_sv: 'Ladda upp senare',
            description_en: 'Upload later' },

          { name:           AdminOnly::FileDeliveryMethod::METHOD_NAMES[:email],
            description_sv: 'Skicka via e-post',
            description_en: 'Send via email' },

          { name:           AdminOnly::FileDeliveryMethod::METHOD_NAMES[:mail],
            description_sv: 'Skicka via vanlig post',
            description_en: 'Send via regular mail' },

          { name:           AdminOnly::FileDeliveryMethod::METHOD_NAMES[:files_uploaded],
            description_sv: 'Alla filer är uppladdade',
            description_en: 'All files are uploaded' }
      ]

      delivery_methods.each do |rec|
        AdminOnly::FileDeliveryMethod.create!(rec)
      end

      log.record('info', "Created #{delivery_methods.size} records.")

    end
  end


  # Geocode all Addresses.
  #   arguments:
  #    sleep:     number of seconds to sleep between each geocode request so we
  #                don't exceed the number of requests per <x> seconds
  #                for Google (or any other service)
  #                Note that 1 Address may require multiple geocode requests
  #                to get a valid locataion if the Address is a 'fake' address.
  #                See the note below about using :geocode_best_possible
  #                 default = 0.2 seconds
  #
  #    batch_num: number of objects in each batch (also so we don't exceed
  #               the number of requests per second)
  #                 default = 50
  #
  # We don't use the geocode:all  rake task
  # because we want to call the :geocode_best_possible method instead of
  # just using the 'geocoded_by :entire_address' that the geocode:all task
  # would use.  We do this because the fake data generated might not
  # create a real address, so the :entire_address might not really give us
  # the geolocation (latitude, longitude) info.
  #
  # This is based on the Geocoder gem geocode:all task.
  # @see https://github.com/alexreisner/geocoder#bulk-geocoding for more info
  #
  # We don't want to exceed the limit of number of geocoding calls per second
  #  (see the Google maps API limits).  We're using the free, standard plan
  # as of 2017-03-29, which means 50 requests per second.
  #
  # Examples:
  #  use the defaults:
  #    rake shf:geolocate_all_addresses
  #
  #  set the number of seconds to sleep between geocoding requests to 3 seconds:
  #    rake shf:geolocate_all_addresses[3]
  #
  #  set the number of records to request in each batch to 19, and number of seconds to sleep = 3:
  #    rake shf:geolocate_all_addresses[3, 19]
  #
  # Note that there are NO SPACES after the commas (between the arguments)
  #
  desc "geocode all addresses args=[sleep_time=2,batch_num=40] (those without latitude, longitude info) NO SPACES between arguments"
  task :geocode_all_addresses, [:sleep_time, :batch_num] => :environment do |_task_name, args|

    args = args.with_defaults(sleep_time: 0.2, batch_num: 50)

    Geocoder.configure(timeout: 20) # geocoding service timeout (secs)

    ActivityLogger.open(LOG_FILE, 'SHF_TASK', 'Geocode Addresses') do |log|

      not_geocoded = Address.not_geocoded

      msg = " #{not_geocoded.count} Addresses are not yet geocoded.  Will geocode."
      log.record('info', msg)

      Address.geocode_all_needed(sleep_between: args[:sleep_time].to_f, num_per_batch: args[:batch_num].to_i)

      msg = " After running Address.geocode_all_needed(sleep_between: " +
          "#{args[:sleep_time].to_f}, num_per_batch: #{args[:batch_num].to_i})" +
          ", #{Address.not_geocoded.count} Addresses are not geocoded."
      log.record('info', msg)
    end
  end


  MEMBER_PAGES_PATH = File.join(Rails.root, 'app', 'views', 'pages') unless defined?(MEMBER_PAGES_PATH)


  desc 'add member page arg=[filename]'
  task :add_member_page, [:filename] => :environment do |task_name, args|


    ActivityLogger.open(LogfileNamer.name_for(MemberPage), 'SHF_TASK', task_name) do |log|

      filename = filename_from_args(args, log)

      if filename =~ /[^\w\-\.]/
        log.record('error', "Unacceptable characters in filename: #{filename}")
        log.record('error', "Acceptable characters are a-z, A-Z, 0-9, '_', '-' and '.'")
        raise 'ERROR: Unacceptable filename'
      end

      # Add html file type if not present
      filename = filename + '.html' unless filename =~ /.*\.html$/

      filepath = File.join(MEMBER_PAGES_PATH, filename)

      unless File.file?(filepath)
        begin
          File.new(filepath, 'w+')
          log.record('info', "Created member page file: #{filename}")
        rescue
          log.record('error', "Cannot create file: #{filename}")
          raise
        end
      else
        log.record('error', 'File already exists in pages directory')
        raise 'ERROR: File already exists in pages directory'
      end
    end
  end


  desc 'delete a member page arg=[filename] (deletes the file from the filesystem)'
  task :delete_member_page, [:filename] => :environment do |task_name, args|

    ActivityLogger.open(LogfileNamer.name_for(MemberPage), 'SHF_TASK', task_name) do |log|

      filename = filename_from_args(args, log)

      member_page_abspath = File.expand_path(File.join(MEMBER_PAGES_PATH, filename))

      if File.exist?(member_page_abspath)
        begin
          File.delete(member_page_abspath)
          log.info( "Member Page file deleted: #{member_page_abspath}")

        rescue => e
          log.error( "Unable to delete #{member_page_abspath}.  Error: #{e}")
          raise e
        end

    else
      error_msg = "Member page file not found: #{member_page_abspath}"
      log.error( error_msg)
      raise error_msg
    end

  end

  end


  def filename_from_args(args, log)
    args.fetch(:filename) do |_key|
      error_message = 'No filename given. You must specify a file name.'
      log.error(error_message)
      raise "ERROR: #{error_message}"
    end
  end


  # Create one org num: "rake shf:orgnum"
  # Create 5 org nums: "rake shf:orgnum[5]"

  desc "Create one or more unused Swedish Organization Numbers (aka 'company numbers' in SHF)"
  task :orgnum, [:how_many] => :environment do |_task_name, args|

    how_many = args.with_defaults(how_many: 1)[:how_many].to_i

    puts "\n#{how_many} available Org (Company) #{'Number'.pluralize(how_many)}: \n\n"

    how_many.times do
      puts create_one_unused_org_number
    end

    puts "\n"
  end


  desc 'show who cannot renew on the given RENEWAL_DATE (String) and why. ex: bundle exec rails shf:show_who_cannot_renew["2021-12-01"] (default is Date.current if no date given) '
  task :show_renewal_status_on, [:renewal_date] => :environment do |_task_name, args|

    require 'awesome_print'

    args = args.with_defaults(renewal_date: Date.current.to_s)

    check_renewal_date = validate_date_arg(args[:renewal_date], 'renewal_date=')


    # Return a list of members that can renew. This is  User.current_member + User.in_grace_period
    # sort by the :id
    def members_to_renew
      (User.current_member + User.in_grace_period).sort_by(&:id)
    end

    # See if each member in the given list can renew on the given date and put the result into a list.
    # Return a list of results for all of the given members
    def can_renew_results(members_to_renew, renewal_date = Date.current)
      renewal_results = []
      (members_to_renew).each do |u|
        req_result = RequirementsForRenewal.requirements_excluding_payments_met?(u, renewal_date)
        renewal_results << {
          user_id: u.id,
          result: req_result,
          failure_reason: RequirementsForRenewal.failed_requirements
        }
      end
      renewal_results
    end

    # show a compact summary of the renewal results (text format)
    def renewal_results_summary(renewal_results = [])
      summary = ''
      renewal_results.each do |result|
        output =  "User [#{result[:user_id]}] #{result[:result] }"
        unless  result[:result]
          output << ':  ' + result[:failure_reason].map{|reason| reason[:string] }.join('; ')
        end
        summary << output + "\n"
      end
      summary
    end


    puts " Checking all users to see if they can renew on #{check_renewal_date}..."

    can_renew_today = (User.current_member + User.in_grace_period ).select { |u| u.valid_date_for_renewal?(check_renewal_date) }
    can_renew_today.count

    reqs_for_renewal_results = []
    (can_renew_today).sort_by{|u| u.id}.each do |u|
      req_result = RequirementsForRenewal.requirements_excluding_payments_met?(u, check_renewal_date)
      reqs_for_renewal_results << {
        user_id: u.id,
        most_recent_membership_first_day: u.most_recent_membership&.first_day,
        most_recent_membership_last_day: u.most_recent_membership&.last_day,
        result: req_result,
        failure_reason: RequirementsForRenewal.failed_requirements
      }
    end


    # show summary of results as CSV :
    summary ="user_id,can renew on #{check_renewal_date}?,most recent membership First Day, Last Day, failure reason(s)\n"
    reqs_for_renewal_results.each do |result|
      output =  "#{result[:user_id]},#{result[:result]},#{result[:most_recent_membership_first_day]},#{result[:most_recent_membership_last_day]}"
      unless  result[:result]
        output << ',"' + result[:failure_reason].map{|reason| reason[:string] }.join('; ') + '"'
      end
      summary << output + "\n"
    end

    puts '========================================================='
    puts "number of Users = #{User.count}"
    puts "eligible to renew on #{check_renewal_date}: #{can_renew_today.count}  (not eligible = #{User.count - can_renew_today.count})"
    puts "can renew: #{reqs_for_renewal_results.select{|results| results[:result]}.count}"
    puts "cannot renew: #{reqs_for_renewal_results.reject{|results| results[:result]}.count}"

    puts "\nSummary in CSV form:\n"
    puts summary
  end


  namespace :seed do
    # This task is needed until we upgrade to Rails 6, which has the db:seed:replant task
    desc 'Delete all SHF data (excluding Rails internal tables) via TRUNCATE statement. Helpful for reseeding'
    task replant: :environment do
      if database_exists?
        rails_internal_tables = %w(ar_internal_metadata schema_migrations)

        connection = ActiveRecord::Base.connection

        tablenames = connection.tables - rails_internal_tables
        connection.disable_referential_integrity do
          tablenames.each { |table_name| connection.exec_query "TRUNCATE TABLE \"#{table_name}\" CASCADE" }
        end

      end

    end
  end

  # -------------------------------------------------

  def create_one_unused_org_number
    org_number = nil

    100.times do
      org_number = OrgNummersGenerator.generate_one

      # stop if number is available (not used)
      break if !Company.find_by_company_number(org_number)
    end

    org_number
  end


  def database_exists?
    ActiveRecord::Base.connection
    rescue ActiveRecord::NoDatabaseError
      false
    else
      true
  end


  def import_a_member_app_csv(row, log)

    log.record('info', "Importing row: #{row.inspect}")

    # log_and_show log, Logger::INFO, "Importing row: #{row.inspect}"

    if (user = User.find_by(email: row[:email]))
      puts_already_exists 'User', row[:email]
    else
      user = User.create!(email: row[:email], password: DEFAULT_PASSWORD)
      puts_created 'User', row[:email]
    end

    company = find_or_create_company(row[:company_number], user.email,
                                     name:         row[:company_name],
                                     street:       row[:street],
                                     post_code:    row[:post_code],
                                     city:         row[:city],
                                     region:       row[:region],
                                     phone_number: row[:phone_number],
                                     website:      row[:website])

    if (membership = ShfApplication.find_by(user: user.id))
      puts_already_exists('Membership application', " org number: #{row[:company_number]}")
    else
      membership = ShfApplication.create!(company_number:    row[:company_number],
                                          first_name:        row[:first_name],
                                          last_name:         row[:last_name],
                                          contact_email:     user.email,
                                          state:             ACCEPTED_STATE,
                                          membership_number: row[:membership_number],
                                          user:              user,
                                          company:           company
      )

      puts_created('Membership application', " org number: #{row[:company_number]}")

    end

    membership = find_or_create_category(row[:category1], membership) unless row[:category1].nil?
    membership = find_or_create_category(row[:category2], membership) unless row[:category2].nil?
    membership.save!

    if membership.accepted?
      membership.company = company
      user.save!
    end

  end


  def find_or_create_category(category_name, membership)
    category = BusinessCategory.find_by_name(category_name)
    if category
      puts_already_exists 'Category', "#{category_name}"
    else
      category = BusinessCategory.create!(name: category_name)
      puts_created 'Category', "#{category_name}"
    end
    membership.business_categories << category
    membership
  end


  def find_or_create_company(company_num, email,
                             name:,
                             street:,
                             post_code:,
                             city:,
                             region:,
                             phone_number:,
                             website:)

    company = Company.find_by_company_number(company_num)
    if company
      puts_already_exists 'Company', "#{company_num}"
    else
      region = Region.find_by name: region
      Company.create!(company_number: company_num,
                      email:          email,
                      name:           name,
                      phone_number:   phone_number,
                      website:        website)

      company = Company.find_by_company_number(company_num)

      company.addresses << Address.new(street_address: street,
                                       post_code:      post_code,
                                       city:           city,
                                       region:         region)

      puts_created 'Company', company.company_number
    end
    company
  end


  def puts_created(item_type, item_name)
    puts " #{item_type} created and saved: #{item_name}"
  end


  def puts_already_exists(item_type, item_name)
    puts " #{item_type} already exists: #{item_name}"
  end


  def puts_error_creating(item_type, item_name)
    puts " ERROR: Could not create #{item_type} #{item_name}.  Skipped"
  end


  def validate_date_arg(date_arg, prefix_str = '')
    Date.iso8601(date_arg)
  rescue ArgumentError => error
    log error, "#{prefix_str}'#{date_arg}' is invalid. Must be YYYY-MM-DD Ex: 2021-02-03 (Date.iso8601 valid format)"
    raise error
  end
end
