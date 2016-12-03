namespace :shf do

  desc 'recreate db (current env): drop, setup, migrate, seed the db.'
  task :db_recreate => [:environment] do
    tasks = ['db:drop', 'db:setup', 'db:migrate', 'db:seed']
    tasks.each { |t| Rake::Task["#{t}"].invoke }
  end

  usage = 'rake shf:import_membership_apps["./spec/fixtures/test-import-files/applications-from-prev-system.csv"]'

  DEFAULT_PASSWORD = 'whatever'
  ACCEPTED_STATUS = 'Accepted'

  require 'csv'
  require 'logger'

  desc "import membership apps from csv file. Provide the full filename (with path)"
  task :import_membership_apps, [:csv_filename] => [:environment] do |t, args|

    # TODO: handle multiple categories
    # TODO: refactor!!!  so. much. commonality
    # TODO - error handling (rescue, log errors)
    # TODO - let user map the keys with the row header names in the csv file (YML?)

    log = ActiveSupport::Logger.new('log/import-members.log')
    start_time = Time.now

    if args.has_key? :csv_filename

      #if File.exists? args[:csv_filename]
        begin
        csv_text = File.read(args[:csv_filename])
        csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
        num_read = 0
        csv.each do |row|
          import_a_member_app_csv(row)
          num_read += 1
        end

        puts "\nFinished.  Read #{num_read} rows."
      rescue LoadError
        log.add(Logger::ERROR,"ERROR:  #{args[:csv_filename]} does not exist. Nothing imported" )
        raise "ERROR:  #{args[:csv_filename]} does not exist. Nothing imported"
      end
    else

      raise "ERROR: You must specify a .csv filename to import. Ex: #{usage}"
    end
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
                             website: )

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

