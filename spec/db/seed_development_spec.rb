require 'rails_helper'

require File.join(__dir__, 'shared_specs_db_seeding')


ENV_ADMIN_EMAIL_KEY = 'SHF_ADMIN_EMAIL'
ENV_ADMIN_PASSWORD_KEY = 'SHF_ADMIN_PWD'
ENV_NUM_SEEDED_USERS_KEY = 'SHF_SEED_USERS'


RSpec.describe 'Dev DB is seeded with users, members, apps, and companies' do

  admin_email = 'the-shfadmin@shf.org'
  admin_pwd = 'insecure-password'


  describe 'inital state before extra info is added' do
    it_behaves_like 'admin, business categories, kommuns, and regions are seeded', 'development', admin_email, admin_pwd
  end

  # seed with a minimum of 4 users to cover: admin, no application, single application, double application
  seed_users = 4


  before(:all) do
    DatabaseCleaner.start
    RSpec::Mocks.with_temporary_scope do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))

      # must stub this way so the rest of ENV is preserved
      stub_const('ENV', ENV.to_hash.merge({ENV_ADMIN_EMAIL_KEY => admin_email,
                                           ENV_ADMIN_PASSWORD_KEY => admin_pwd,
                                           ENV_NUM_SEEDED_USERS_KEY => seed_users}) )
      SHFProject::Application.load_tasks
      SHFProject::Application.load_seed
    end
  end

  after(:all) do
    DatabaseCleaner.clean
    Rake::Task['shf:load_regions'].reenable
    Rake::Task['shf:load_kommuns'].reenable
  end


  it 'users are in the db' do
    expect(User.all.size).to eq(seed_users)
  end

  it 'addresses are in the db' do
    expect(Address.count).to eq(ShfApplication.count)
  end

  it 'companies are in the db' do
    expect(Company.count).to eq(ShfApplication.count)
  end

  it 'memberships applications are in the db' do
    expect(ShfApplication.all.size).to eq(seed_users-1)
  end

end
