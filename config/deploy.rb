# Tasks to run to deploy the application.  Tasks defined here will be called by capistrano.

# If you are not familiar with Capistrano, you should read the documentation:
#   https://capistranorb.com/
#   https://github.com/capistrano/rails
#
# In addition, here are a few helpful links:
#   Good basic example of entire process using capistrano to deploy a Ruby on Rails application: https://semaphoreci.com/community/tutorials/how-to-use-capistrano-to-deploy-a-rails-application-to-a-puma-server
#   Good write-up explaining some about capistrano: https://piotrmurach.com/articles/working-with-capistrano-tasks-roles-and-variables/
#
#
# Note: Many comments are commands/statements that can be run locally instead of on a remote server, e.g. when developing
#

# ============================================
# Capistrano configuration settings
#

# config valid only for Capistrano 3.11
lock '~> 3.11'
set :rbenv_type, :user
set :rbenv_ruby, '2.7.6'

set :application, 'shf'
set :repo_url, ENV['SHF_GIT_REPO']
set :branch, ENV['SHF_GIT_BRANCH']

set :deploy_to, ENV['SHF_APP_PATH']

# Ensure the binstubs (files in /bin) are generated on each deploy. (From capistrano-bundle gem: https://github.com/capistrano/bundler)
set :bundle_binstubs, -> { shared_path.join('bin') }

# So we can see exactly what happens for debugging, do not use the default --quiet flag
set :bundle_flags, ''

set :keep_releases, 5

set :migration_role, :app


# -----------------------------------------------------------------
# Map Markers
#  The map marker files are used to display markers on Google maps.
#
#  We require 6 (!) directories for the map markers:
#   public/map-markers,    ** this is the definitive directory
#   public/sv/map-markers,
#   public/sv/hundforetag/map-markers,
#   public/en/map-markers,
#   public/en/hundforetag/map-markers,
#   public/hundforetag/map-markers,
#
#  The 'source' (main) files are in the public/map-markers directory.
#
#  The application will create paths with the locale [sv|en] prepended, and then google-maps.js will
#  use those in the relative path that it constructs to get the map-marker image files (m*.png files).
#  The application creates the locale paths because of the locale filter gem (used in the routes.rb) file.
#  The root route (for non-logged in visitors) will look for the map markers in /public[/sv|en]/map-markers.
#  But often the path is specific to companies and so is /public[/sv|en]/hundforetag
#
#   (This all seems a bit too complex, but it's what is needed to get this working.)
#
#  The definitive directory is public/map-markers and it must have all of the map-marker files.
#  The other directories/files are just symbolic links too the definitive directory and files.
#
#  The definitive directory and files _must_ exist. A task checks to see if they do and fails if they don't.
#  The symbolic links are all created in another task.
#
set :map_marker_parent_dir, 'public'
set :map_marker_dir, 'map-markers'
set :map_marker_filenames, ['m1.png', 'm2.png', 'm3.png', 'm4.png', 'm5.png']
set :locale_prefixes, ['sv', 'en']
set :map_marker_linked_dirs, ['hundforetag']


# @return Pathname - top-level path (within the Rails app) where the map-marker directory resides (the parent of the map-marker directory)
def mapmarkers_parent_path
  release_path.join(fetch(:map_marker_parent_dir))
end


# @return Pathname - full path (within the Rails app) for the definitive map-markers directory
def mapmarkers_main_path
  mapmarkers_parent_path.join(Pathname.new(fetch(:map_marker_dir)))
end


# --------------------------


def required_linked_files
  rails_files = ['config/database.yml',
                 'config/secrets.yml',
                 '.env',
                 'public/robots.txt',
                 'public/favicon.ico',
                 'public/apple-touch-icon.png',
                 'public/apple-touch-icon-precomposed.png']

  google_webmaster_files = ['public/google052aa706351efdce.html',
                            'public/google979ebbe196e9bd30.html']

  sitemap_files = ['public/sitemap.xml.gz',
                   'public/svenska.xml.gz',
                   'public/english.xml.gz']

  [] + rails_files + google_webmaster_files + sitemap_files
end


# -------------------
# LINKED DIRECTORIES
#
# These directories are shared among all deployments.  Every deployment has a
# link to these directories.  They are not recreated (new) for each deployment.
# If any information or data for the system must remain the same from one
# deployment to the next, it should be listed here.
# These directories are in the 'shared' directory on the production system: /var/www/shf/shared/
# (That is the convention for Capistrano deployments.)

# public/system       created by diffouo (raoul) when this was set up. used for ??? (not used?)
# public/uploads      created by diffouo (raoul) when this was set up. used for ??? (not used?)

append :linked_dirs, 'log',
       'tmp/pids',
       'tmp/cache',
       'tmp/sockets',
       'vendor/bundle',
       'public/system',
       'public/uploads'

# Files uploaded for membership applications
append :linked_dirs, 'public/storage'

# Member Documents are stored here:  (Eventually they should moved to a different directory)
append :linked_dirs, 'app/views/pages'

# Files uploaded by members and admins when using the ckeditor (ex: company page custom infor, SHF member documents)
append :linked_dirs, 'public/ckeditor_assets'


# Tasks that should be run just once.
#  Files are renamed once they are run, so we don't want to keep overwriting them each time we deploy.
append :linked_dirs, 'lib/tasks/one_time'

# per the capistrano-bundle gem (https://github.com/capistrano/bundler), this needs to be added to linked_dirs:
append :linked_dirs, '.bundle'


# ============================================
# Tasks
#   See Task sequencing below, after the code for the tasks

namespace :shf do

  desc 'show all Capistrano variables'
  task :show_cap_vars do
    all_variables = Capistrano::Configuration.env
    pp all_variables
  end


  namespace :deploy do

    # this ensures that the description (a.k.a. comment) for each task will be recorded
    Rake::TaskManager.record_task_metadata = true


    desc 'If req.d files are not in shared, copy from current release then update linked_files list'
    task :append_reqd_linked_files do

      shared_path = deploy_path.join(fetch(:shared_directory, 'shared'))
      current_release_path = deploy_path.join(fetch(:release_path, '.'))

      on release_roles :all do
        # If it doesn't already exist in the shared directory,
        #   move the file from the release directory to the shared directory

        required_linked_files.each do |reqd_file|
          source = current_release_path.join(reqd_file)
          destination = shared_path.join(reqd_file)

          unless test "[ -f #{destination} ]"
            if test "[ -f #{source} ]"
              # ensure the directory exists on the destination so that we can move the file there
              execute :mkdir, "-p", destination.parent
              execute(:mv, source, destination)
            end
          end

        end
      end

      # Can't set the linked_files for capistrano because if this is the very first
      #   installation, the files won't exist.  And the capistrano task deploy:check:linked_files will fail.
      # Now add the files so that that they can be linked by later tasks
      append :linked_files, *required_linked_files

    end


    # ----------------------------

    namespace :check do
      desc 'Ensure public/map-marker files exist. (Needed for Google maps)'
      task :main_mapmarker_files_exist do

        on release_roles :all do |host|
          target_markers_path = mapmarkers_main_path
          source_files = fetch(:map_marker_filenames, [])

          source_files.each do |marker_file|
            full_fn = target_markers_path.join(marker_file)
            unless test "[ -f #{full_fn} ]"
              # unless File.exist?(full_fn)
              error "Map marker file #{full_fn} must exist but doesn't.  host: #{host}"
              exit 1
            end
          end
        end
      end

    end


    desc 'Create sym links to public/map-markers files. Always remove any existing links and recreate them'
    task symlink_dirs_to_mapmarkers: ["deploy:set_rails_env", "shf:deploy:check:main_mapmarker_files_exist"] do


      # ensure we're working with a Pathname vs. a String
      # @return Pathname - constructed with the string representation of what was given
      def make_path(str_or_path = '')
        Pathname(str_or_path.to_s)
      end


      # @return Pathname with the map-markers directory appended
      def append_mapmarkers_dir(given_dir)
        make_path(given_dir).join(fetch(:map_marker_dir))
      end


      # Always recreate the link so that we ensure it is up to date (= '-f' option)
      # If the link already exists, force an overwrite (-f)
      # If a directory exists with the same name as the link, remove it (must use 'rm -r')
      def recreate_symlinked_dir(orig_dir, symlinked_dir)
        execute(:rm, "-r", symlinked_dir) if test " [ -d #{symlinked_dir} ] "
        execute :ln, "-sTf", orig_dir, symlinked_dir
      end


      on release_roles :all do |_host|

        # create locale dirs based on the mapmarkers_main_path
        # add a link to the map-markers directory
        # don't delete the locale dirs if they already exist; we'll need to add to them
        fetch(:locale_prefixes).each do |locale|
          parent_path_with_locale = mapmarkers_parent_path.join(locale)
          execute :mkdir, "-p", parent_path_with_locale
          recreate_symlinked_dir(mapmarkers_main_path, append_mapmarkers_dir(parent_path_with_locale))
        end

        # Dirs that need to have locales prepended and a link to map-markers in each
        fetch(:map_marker_linked_dirs, []).each do |linked_dirname|

          # First: create the dir without any locale and put the a link to map-markers in it
          linked_dir_path_no_locale = mapmarkers_parent_path.join(linked_dirname)
          execute :mkdir, "-p", linked_dir_path_no_locale
          recreate_symlinked_dir(mapmarkers_main_path, append_mapmarkers_dir(linked_dir_path_no_locale))

          # Second: create dirs with the locale prefixes and put the link to map-markers in each
          fetch(:locale_prefixes).each do |locale|
            linked_dir_path_w_locale = mapmarkers_parent_path.join(locale).join(linked_dirname)
            execute :mkdir, "-p", linked_dir_path_w_locale
            recreate_symlinked_dir(mapmarkers_main_path, append_mapmarkers_dir(linked_dir_path_w_locale))
          end
        end

      end
    end


    desc 'run load_conditions task to put conditions into the DB'
    task run_load_conditions: ["deploy:set_rails_env"] do |this_task|
      info_if_not_found = "The Conditions will NOT be loaded into the database. (task #{this_task} in #{__FILE__ })"
      run_task_from(this_task, 'shf:load_conditions', info_if_not_found)
    end


    desc 'run any one-time tasks that have not yet been run successfully'
    task run_one_time_tasks: ["deploy:set_rails_env"] do |this_task|
      info_if_not_found = "No 'one_time' tasks will be run! (task #{this_task} in #{__FILE__ })"
      run_task_from(this_task, 'shf:one_time:run_onetime_tasks', info_if_not_found)
    end


    desc 'Restart application'
    task :restart do
      on roles(:app), in: :sequence, wait: 5 do
        info 'Restarting Rails server...'
        execute :touch, release_path.join('tmp/restart.txt')
      end
    end


    desc 'Remove testing related files'
    task :remove_test_files do

      on release_roles :all do

        # 'current' directory might not exist yet (e.g. for an initial deploy). So must use :release_path
        current_release_path = deploy_path.join(fetch(:release_path, '.'))

        # Because gems for these are not deployed,
        # Rake cannot load these files,
        # which then causes problems when trying to run any rake tasks on the deployment server.
        remove_files = [current_release_path.join("lib/tasks/ci.rake"),
                        current_release_path.join("lib/tasks/cucumber.rake"),
                        current_release_path.join("script/cucumber")].freeze
        remove_files.each { |remove_f| remove_file remove_f }


        # Remove testing directories since the gems for using them are not deployed.
        remove_dirs = [current_release_path.join("spec"),
                       current_release_path.join("features")].freeze
        remove_dirs.each { |remove_d| remove_dir remove_d }

      end

    end


    # ----------------------------------------------------
    # Supporting methods
    # ----------------------------------------------------

    # execute a task and show an info line
    # If the task is not defined, print out the warning with info_if_missing appended.
    def run_task_from(_calling_task, task_name_to_run, info_if_missing = '')

      on release_roles :all do
        within release_path do
          with rails_env: fetch(:rails_env) do

            if task_is_defined?(task_name_to_run)
              #info task_invoking_info(calling_task.name, task_name_to_run)
              execute :rake, task_name_to_run
            else
              puts "\n>> WARNING! No task named #{task_name_to_run}. #{info_if_missing}\n\n" # TODO can this be 'warn' instead of 'puts' ?
            end
          end
        end
      end
    end


    # information string about a task that invoked another one
    def task_invoking_info(task_name, task_invoked_name)
      "[#{task_name}] invoking #{task_invoked_name}"
    end


    def remove_file(full_fn_path)
      if test("[ -f #{full_fn_path} ]") # if the file exists on the remote server
        execute %{rm -f #{full_fn_path} }
      else
        warn "File doesn't exist, so it could not be removed: #{full_fn_path}"
      end
    end


    def remove_dir(full_dir_path)
      if test("[ -d #{full_dir_path} ]") # if the directory exists on the remote server
        execute %{rm -r #{full_dir_path} }
      else
        warn "Directory doesn't exist, so it could not be removed: #{full_dir_path}"
      end
    end


    def task_is_defined?(task_name)
      puts "( Checking to see if task #{task_name} is defined. This calls the parser.)"
      result = %x{bundle exec rake --tasks #{task_name} }
      result.include?(task_name) ? true : false
    end

  end

  desc 'refresh sitemaps'
  task sitemap_refresh: ["deploy:set_rails_env"] do |this_task|
    run_task_from(this_task, 'sitemap:refresh', 'Unable to refresh the SITEMAPs (/public/sitemap.* ...)')
  end


  desc 'celebrate success!'
  task :hooray do
    yay_words = ['HOORAY!', 'Excellent!', 'Whoopee!', 'YAY!', 'Jippie!', 'Eccellente!', 'Woo Hoo!', 'Fantasic!']
    random_yay = yay_words.sample
    puts "\n\n\n     #{random_yay}  The system deployed successfully. \n\n\n"
  end


end


# =========================================================
# Rails tasks
#
# Run a rails console or a rails dbconsole
# @url https://gist.github.com/toobulkeh/8214198
#
# Note: this assumes that there is a /bin/rails  file that is capable of
# running a rails console.
#
# Usage:
#  bundle exec cap production rails:console
#  bundle exec cap production rails:dbconsole
namespace :rails do
  desc "Open the rails console"
  task :console do
    on roles(:app) do
      rails_env = fetch(:rails_env, 'production')
      execute_interactively "$HOME/.rbenv/bin/rbenv exec bundle exec rails console #{rails_env}"
    end
  end

  desc "Open the rails dbconsole"
  task :dbconsole do
    on roles(:app) do
      rails_env = fetch(:rails_env, 'production')
      execute_interactively "$HOME/.rbenv/bin/rbenv exec bundle exec rails dbconsole #{rails_env}"
    end
  end


  # ssh to the server
  def execute_interactively(command)
    server = fetch(:bundle_servers).first
    user = server.user
    port = server.port || 22

    exec "ssh -l #{user} #{host} -p #{port} -t 'cd #{deploy_to}/current && #{command}'"
  end
end


# ----------------------------------------------------
# Task sequencing:
# ----------------------------------------------------

before "deploy:symlink:linked_files", "shf:deploy:append_reqd_linked_files"

after "deploy:symlink:linked_dirs", "shf:deploy:symlink_dirs_to_mapmarkers"

# Have to wait until all files are copied and symlinked before trying to remove
#   these files.  (They won't exist until then.)
# They must be removed before deploy:assets:precompile is executed because
#   that will cause all rake files to be loaded and if any testing .rake or .rb files are referenced,
#   it will fail.
before "deploy:assets:precompile", "shf:deploy:remove_test_files"

before "deploy:publishing", "shf:deploy:run_load_conditions"
after "shf:deploy:run_load_conditions", "shf:deploy:run_one_time_tasks"

after "deploy:published", "shf:deploy:restart"

# Refresh the sitemaps
after "shf:deploy:restart", "shf:sitemap_refresh"

after "deploy:finished", "shf:hooray"
