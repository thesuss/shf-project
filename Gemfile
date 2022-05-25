source 'https://rubygems.org'
ruby '2.7.6'

gem 'dotenv-rails'
gem 'rails', '~> 5.2.7.1'
gem 'bootsnap', require: false

gem 'pg', '~> 1.2'
gem 'scenic' # DB views and materialized views

gem 'sass-rails'

gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

gem 'bcrypt', '~> 3.1'

# Updating to sprockets 4 needs to be done carefully to ensure that
#   assets are served correctly in PRODUCTION
gem 'sprockets', '< 4.0'

gem 'haml-rails'
gem 'high_voltage', '~> 3.0'
gem 'orgnummer'
gem 'popper_js', '~> 1.14.3'
gem 'bootstrap', '~> 4'
gem 'font-awesome-sass', '~> 5.5'  # , '~> 5.5.0'
gem 'bootstrap-toggle-rails'

gem 'devise'
gem 'pundit'
# gem "paperclip"
gem "kt-paperclip", "~> 7.0.0"

gem 'routing-filter'   # for handling locale filters around routes

gem 'ransack'
gem 'city-state'
gem 'rubyzip', '>= 1.2.1'  # security vulnerability with earlier versions CVE-2017-5946
gem 'i18n-js' #, '>= 3.0.0.rc11'

gem 'will_paginate'
gem 'bootstrap-will_paginate'

gem 'ckeditor', '~> 4.2', '>= 4.2.4'
# ^^ https://github.com/galetahub/ckeditor/issues/718

gem 'aasm'    # state machine

gem 'ffaker'  # Fake data for DB seeding

gem 'dotenv'


gem 'smarter_csv'

gem 'geocoder'

gem 'sanitize'

gem 'mailgun-ruby'
gem 'premailer-rails'  # converts css to inline; required for html emails to look ok
gem 'nokogiri', '>= 1.13.4', platforms: :ruby # must explicitly require this gem for premailer-rails

gem 'httparty'
gem 'jwt'

gem 'exception_notification' # send notifications if there are errors
gem 'slack-notifier'  # send notifications to Slack
gem 'exception_notification-rake', '~> 0.3.0'

gem 'imgkit'
gem 'wkhtmltoimage-binary'
gem 'chartkick'
gem 'groupdate'

# rubocop:disable Bundler/DuplicatedGem
if RUBY_PLATFORM =~ /aarch/
  # these gem versions support arm
  gem 'mini_racer', '0.5.0.pre'
  gem 'libv8-node', '16.10.0.0'
else
  # these gem versions don't support arm
  gem 'mini_racer', platforms: :ruby
  gem 'libv8-node', platforms: :ruby # use libv8-node to be in sync with aarch (ARM) architecture
end
# rubocop:enable Bundler/DuplicatedGem


gem 'hashie'  # powerful methods for searching nested Hashes (ex: params) and more

gem 'aws-sdk-s3'

gem 'meta-tags'
gem 'mini_magick'

gem 'counter_culture', '~> 2.0'

gem 'ancestry'

gem 'cookies_eu'

gem 'sitemap_generator'

gem 'whenever', require: false

# Query ActiveRecord by time
# (ex:  Payment.by_year(2019), Payment.between_times(Time.zone.now - 3.hours, Time.zone.now))
# # all posts in last 3 hours
gem 'by_star'


# This is used by capybara, webmock, and more.
# It is listed here only so we can specify the version that addresses a security vulnerability.
# (see entry in Github advisory db: https://github.com/advisories/GHSA-jxhc-q857-3j6g)
gem 'addressable', '>= 2.8.0'

# Use this even in production to help examine data in the production system
gem 'awesome_print', require: false

# PDF Generation
gem 'pdfkit'
gem 'wkhtmltopdf-binary'
# gem 'wkhtmltopdf-heroku' if ENV['HEROKU_STAGING']  # is this even needed?

gem 'exception_handler', '~> 0.8.0', git: 'https://github.com/weedySeaDragon/exception_handler'


group :development, :test do
  gem 'puma', '>= 5.6.4'  # passenger is used on the production system

  gem 'rubocop',             '= 1.22.1', require: false
  gem 'rubocop-rails',       '= 2.13.2', require: false
  gem 'rubocop-rspec',       '= 2.9.0', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-performance', '= 1.13.2', require: false

  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'pundit-matchers'
  gem 'factory_bot_rails'

  # Note: pry fails when a utf-8 character is used in a string.
  # pry calls the rb-readline gem, which is actually where the failure happens.
  # gem 'pry-rails'
  gem 'pry'
  gem 'pry-byebug'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rake'
  gem 'coveralls', '>= 0.8.23', require: false
  gem 'launchy'
  gem 'cucumber-timecop', require: false

  gem 'better_errors'
  gem 'binding_of_caller'  # needed to make better_errors work well

  gem 'i18n-tasks'

  gem 'spring-commands-rspec'
end

group :development do
  gem 'web-console'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'erb2haml'
  gem 'capistrano' #, '~> 3.11'
  gem 'capistrano-bundler' #, '~> 1.6'
  gem 'capistrano-rails' #, '~> 1.4'
  gem 'capistrano-rbenv' #, '~> 2.0'
  gem 'capistrano-ssh-doctor' #, '~> 1.0'
  gem 'capistrano-env-config'
  gem 'railroady'
  gem 'bullet'
  gem 'rb-readline'

  # gem 'rubycritic', '>= 4.4'   # code quality analysis tools and reports
  # FIXME: rubycritic requires simplecov >= 0.17.0 but coveralls requires ~> 0.16.1 (which is any version < 0.17.0)
  #    The coveralls gem is not being maintained.

  gem 'rack-mini-profiler', require: false
end

group :test do
  gem 'codeclimate-test-reporter' #, '~> 1.0.0'
  # ^^ https://docs.codeclimate.com/docs/test-coverage-ruby
  gem 'simplecov' #, '>= 0.13.0'
  gem 'email_spec'
  gem 'selenium-webdriver'

  # the gem doesn't support arm yet (see: https://github.com/titusfortner/webdrivers/issues/213)
  gem 'webdrivers' unless RUBY_PLATFORM =~ /aarch/  # Performance/RegexpMatch


  gem 'webmock'  # to mock web (HTTP) interactions.  Required by the vcr gem
  gem 'vcr'      # to record and 'playback' (mock) http requests

  gem 'timecop'

  gem "show_me_the_cookies"
end
