require 'active_support/logger'


namespace :shf do

  desc 'recreate db (current env): drop, setup, migrate, seed the db.'
  task :db_recreate => [:environment] do
    tasks = ['db:drop', 'db:setup', 'db:migrate', 'db:seed']
    tasks.each { |t| Rake::Task["#{t}"].invoke }
  end


  desc "get valid company numbers from a text file. Expects to find them as Org no556357-3046 (no space after 'Org no'"
  task :get_valid_companyNums, [:text_file] => [:environment] do |t, args|
    # ex: text copied from https://foretagsfakta.bolagsverket.se/fpl-dft-ext-web/home.seam?actionMethod=home.xhtml%3Asearch.sokning.prevPage&cid=234026

    usage = 'rake shf:get_valid_companyNums["./spec/fixtures/test-import-files/company-numbers-source.txt"]'
    match_pattern = /Org no(\d\d\d\d\d\d-\d\d\d\d)/

    start_time = Time.now
    log = start_logging(start_time)

    if args.has_key? :text_file

      if File.exists? args[:text_file]
        contents = File.open(args[:text_file], 'r') { |f| f.read }
        contents = contents.scrub '*' # file has some bad encoding, so have to do this

        company_numbers =  contents.scan match_pattern
        log_and_show log, Logger::INFO, "#{company_numbers.flatten}"

      else
        log_file_doesnt_exist_and_close(log, args[:text_file], start_time)
        raise LoadError
      end
    else
      log_must_provide_filename_and_close(log, usage, start_time)
      raise "ERROR: You must specify a .csv filename to import. Ex: #{usage}"
    end

    finish_and_close_log(log, start_time, Time.now)
  end


  desc 'copies given csv file, replaces org numbers and email with fake ones. saves as fake-<filename>'
  task :copy_and_replace_orgNums_emails_with_fakes, [:csv_filename] => [:environment] do |t, args|

    start_time = Time.now
    log = start_logging(start_time)

    finish_and_close_log(log, start_time, Time.now)
  end


  desc "import membership apps from csv file. Provide the full filename (with path)"
  task :import_membership_apps, [:csv_filename] => [:environment] do |t, args|

    require 'csv'
    # TODO: handle multiple categories
    # TODO: refactor!!!  so. much. commonality.
    # TODO - error handling (rescue, log errors)
    # TODO - let user map the keys with the row header names in the csv file (YML?)
    #   smarter_csv gem? https://github.com/tilo/smarter_csv

    usage = 'rake shf:import_membership_apps["./spec/fixtures/test-import-files/member-companies-sanitized-small.csv"]'

    DEFAULT_PASSWORD = 'whatever'
    ACCEPTED_STATUS = 'Accepted'

    start_time = Time.now
    log = start_logging(start_time)

    if args.has_key? :csv_filename

      if File.exists? args[:csv_filename]
        csv_text = File.read(args[:csv_filename])
        csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
        num_read = 0
        csv.each do |row|
          import_a_member_app_csv(row)
          num_read += 1
        end

        puts "\nFinished.  Read #{num_read} rows."
      else
        log_file_doesnt_exist_and_close(log, args[:csv_filename], start_time)
        finish_and_close_log(log, start_time, Time.now)
        raise LoadError
      end

    else
      log_must_provide_filename_and_close(log, usage, start_time)
      raise "ERROR: You must specify a .csv filename to import. Ex: #{usage}"
    end

    finish_and_close_log(log, start_time, Time.now)
  end




  def start_logging(start_time = Time.now, log_fn = 'log/import.log')
    log = ActiveSupport::Logger.new(log_fn)
    log_and_show log, Logger::INFO, "Import started at #{start_time}"
    log
  end

  # Severity label for logging (max 5 chars).
  LOG_LEVEL_LABEL = %w(DEBUG INFO WARN ERROR FATAL ANY).each(&:freeze).freeze

  def log_level_text(log_level)
    LOG_LEVEL_LABEL[log_level] || 'ANY'
  end


  def log_and_show(log, log_level, message)
    log.add log_level, message
    puts "#{log_level_text(log_level)}: #{message}"
  end


  def log_file_doesnt_exist_and_close(log, filename, start_time, end_time=Time.now)
    log_and_show log, Logger::ERROR, "#{filename} does not exist. Nothing imported"
    finish_and_close_log(log, start_time, end_time)
  end


  def log_must_provide_filename_and_close(log, usage_example, start_time, end_time=Time.now)
    log_and_show(log, Logger::ERROR, "You must specify a .csv filename to import.\n  Ex: #{usage_example}")
    finish_and_close_log(log, start_time, end_time)
  end


  def finish_and_close_log(log, start_time, end_time)
    duration = (start_time - end_time) / 1.minute
    log_and_show log, Logger::INFO, "Import finished at #{start_time}.\n"
    log.close
    log
  end


  def import_a_member_app_csv(row)

    puts "Importing row: #{row.inspect} ..."

    ##
    # row headers:
    ## membership_number;
    # email;
    # company_number;
    # first_name;
    # last_name;
    # company_name;
    # street;
    # post_code;
    # stad;
    # region;
    # phone_number;
    # website;
    # category;
    # category
    #
    # TODO convert string keys to symbols -- then I can splat them into the methods


    if (user = User.find_by(email: row['email']))
      puts_already_exists 'User', row['email']
    else
      user = User.create!(email: row['email'], password: DEFAULT_PASSWORD)
      puts_created 'User', row['email']
    end

    if (membership = MembershipApplication.find_by(user: user.id))
      puts_already_exists('Membership application', " org number: #{row['company_number']}, status: #{row['status']}")
      # TODO: update info
    else
      category1 = find_or_create_category row['category']

      membership = MembershipApplication.create!(company_number: row['company_number'],
                                                 first_name: row['first_name'],
                                                 last_name: row['last_name'],
                                                 contact_email: user.email,
                                                 status: ACCEPTED_STATUS,
                                                 membership_number: row['membership_number'],
                                                 user: user
      )


      if membership
        puts_created('Membership application', " org number: #{row['orgnr']}, status: #{row['status']}")

        if membership.status == ACCEPTED_STATUS
          membership.company = find_or_create_company(row['company_number'], user.email,
                                                      name: row['company_name'],
                                                      street: row['street'],
                                                      post_code: row['post_code'],
                                                      stad: row['stad'],
                                                      region: row['region'],
                                                      phone_number: row['phone_number'],
                                                      website: row['website']
          )
          user.is_member = true
          user.save!
        end
      else
        puts "  Error: Membership application couldn't be created."
      end

    end


  end


  def find_or_create_category(category_name)
    category = BusinessCategory.find_by_name(category_name)
    if category
      puts_already_exists 'Category', "#{category_name}"
      # TODO: update info
    else
      category = BusinessCategory.create!(name: category_name)
      puts_created 'Category', "#{category_name}"
    end
    category
  end


  def find_or_create_company(company_num, email,
                             name:,
                             street:,
                             post_code:,
                             stad:,
                             region:,
                             phone_number:,
                             website:)

    company = Company.find_by_company_number(company_num)
    if company
      puts_already_exists 'Company', "#{company_num}"
      # TODO: update info
    else
      Company.create!(company_number: company_num,
                      email: email,
                      name: name,
                      street: street,
                      post_code: post_code,
                      city: stad,
                      region: region,
                      phone_number: phone_number,
                      website: website)

      company = Company.find_by_company_number(company_num)
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

end

