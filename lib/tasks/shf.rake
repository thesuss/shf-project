namespace :shf do

  desc 'recreate db (current env): drop, setup, migrate, seed the db.'
  task :db_recreate => [:environment] do
    tasks = ['db:drop', 'db:setup', 'db:migrate', 'db:seed']
    tasks.each { |t| Rake::Task["#{t}"].invoke }
  end


  usage = 'rake shf:import_membership_apps["csv-file-with-full-path.csv"]'

  DEFAULT_PASSWORD = 'whatever'

  require 'csv'

  desc "import membership apps from csv file. Provide the full filename (with path)"
  task :import_membership_apps, [:csv_filename] => [:environment] do |t, args|

    puts args.inspect
    if args.has_key? :csv_filename
      puts args[:csv_filename]
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
        raise "ERROR:  #{args[:csv_filename]} does not exist. Nothing imported"
      end
    else
      raise "ERROR: You must specify a .csv filename to import. Ex: #{usage}"
    end
  end


  def import_a_member_app_csv(row)

    puts "Importing #{row['email']} ..."

    if (user = User.find_by(email: row['email']))
      puts_already_exists 'User', row['email']
    else
      user = User.create!(email: row['email'], password: DEFAULT_PASSWORD)
      puts_created 'User', row['email']
    end

    if (membership = MembershipApplication.find_by(user: user.id))
      puts_already_exists('Membership application', " org number: #{row['orgnr']}, status: #{row['status']}")
    else
      membership = MembershipApplication.create!(company_number: row['orgnr'],
                                                 first_name: row['first_name'],
                                                 last_name: row['last_name'],
                                                 contact_email: user.email,
                                                 status: row['status'],
                                                 user: user
      )


      if membership
        puts_created('Membership application', " org number: #{row['orgnr']}, status: #{row['status']}")

        if membership.status == 'approved'
          membership.company = find_or_create_company(row['orgnr'], user.email)
          user.is_member = true
          user.save!
        end
      else
        puts "  Error: Membership application couldn't be created."
      end

    end


  end


  def find_or_create_company(company_num, email)
    company = Company.find_by_company_number(company_num)
    if company
      puts_already_exists 'Company', "#{company_num}"
    else
      Company.create!(company_number: company_num, email: email)
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

