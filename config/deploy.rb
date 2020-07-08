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
set :rbenv_ruby, '2.5.1'

set :application, 'shf'
set :repo_url, 'git@github.com:AgileVentures/shf-project.git'
set :branch, ENV['BRANCH']

set :deploy_to, ENV['APP_PATH']

# Ensure the binstubs (files in /bin) are generated on each deploy. (From capistrano-bundle gem: https://github.com/capistrano/bundler)
set :bundle_binstubs, -> { shared_path.join('bin') }

set :keep_releases, 5

set :migration_role, :app


# -------------------------
# Map Markers
#  The map marker files are used to display markers on Google maps.
#
#  We require 6 (!) directories for the map markers:
#   public/map-markers,
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
#  /sv/[hundforetag/]map-markers and /en/[hundforetag/]map-markers just have symbolic markers to the public/map-markers directory.
#   (This all seems a bit too complex, but it's what is needed to get this working.)
set :map_marker_root_dir, 'public'
set :map_marker_dir, 'map-markers'
set :map_marker_linked_dirs, ['sv', 'en', 'hundforetag', 'sv/hundforetag', 'en/hundforetag']
set :map_marker_filenames, ['m1.png', 'm2.png', 'm3.png', 'm4.png', 'm5.png']


def mapmarker_root_path
  # map_marker_root_dir = 'public'
  # shared_path = Pathname.new('.')
  # mapmarker_root_path = shared_path.join(map_marker_root_dir)
  shared_path.join(fetch(:map_marker_root_dir))
end


def mapmarker_main_path
  # map_marker_dir = 'map-markers'
  # markers_path = Pathname.new(map_marker_dir)
  markers_path = Pathname.new(fetch(:map_marker_dir))
  mapmarker_root_path.join(markers_path)
end


# @return Array[String] - list of all files in the main mapmarkers directory
def mapmarker_main_files
  # ['m1.png', 'm2.png', 'm3.png', 'm4.png', 'm5.png']
  fetch(:map_marker_filenames, [])
end


def mapmarker_linked_paths
  # markerlinked_dirs = ['sv', 'en','hundforetag','sv/hundforetag', 'en/hundforetag']
  # map_marker_dir = 'map-markers'
  markerlinked_dirs = fetch(:map_marker_linked_dirs, [])
  map_marker_dir = fetch(:map_marker_dir)
  markerlinked_dirs.map { |marker_linked_dir| mapmarker_root_path.join(marker_linked_dir).join(map_marker_dir) }
end


# @return Array[String] - list of all Map Marker directories, including those that are symlinks.
#   Note these are not Pathnames
def all_mapmarker_dirs
  ["#{mapmarker_main_path}"].concat(mapmarker_linked_paths.map(&:to_s))
end


# @return Array[String] - list of all Map Marker files in all directories, including those that are symlinks
def all_mapmarker_fpaths
  all_fpaths = []
  all_mapmarker_dirs.each do |mapmarker_dir|
    all_fpaths.concat(mapmarker_main_files.map { |source_fn| "#{mapmarker_dir}/#{source_fn}" })
  end
  all_fpaths
end


# -------------------
# LINKED FILES
#
# These files are shared among all deployments.  Every deployment has a
# link to these files.  They are not recreated (new) for each deployment.
# If any specific file for the system must remain the same from one
# deployment to the next, it should be listed here.
# These individual files are in the 'shared' directory on the production system:
#     /var/www/shf/shared/
# (That is the convention for Capistrano deployments.)
#
append :linked_files, 'config/database.yml',
       'config/secrets.yml',
       '.env',
       'public/robots.txt',
       'public/favicon.ico',
       'public/apple-touch-icon.png',
       'public/apple-touch-icon-precomposed.png'

# Sitemap files.  These are generated by the sitemap_generator gem. (They are generated by a task, using the config/sitemap.rb configuration file)
append :linked_files,
       'public/sitemap.xml.gz',
       'public/svenska.xml.gz',
       'public/english.xml.gz'

# Google webmaster files
# The public/google......html files are files that Google Webmaster tools looks
#   for to verify ownership and access to this site.
#   These files verify that Google webmasters (e.g. Susanna & Ashley as of 2020/02/02)
#   are verified as to access this site with Google webmaster tools.
#   Do not remove these files!
append :linked_files,
       'public/google052aa706351efdce.html',
       'public/google979ebbe196e9bd30.html'

# Map marker files.
append :linked_files, *all_mapmarker_fpaths


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

# Map Marker directories:
append :linked_dirs, *all_mapmarker_dirs

# Tasks that should be run just once.
#  Files are renamed once they are run, so we don't want to keep overwriting them each time we deploy.
append :linked_dirs, 'lib/tasks/one_time'

# per the capistrano-bundle gem (https://github.com/capistrano/bundler), this needs to be added to linked_dirs:
append :linked_dirs, '.bundle'


# ============================================
# Tasks
#   See Task sequencing below, after the code for the tasks

namespace :shf do

  namespace :deploy do

    # this ensures that the description (a.k.a. comment) for each task will be recorded
    Rake::TaskManager.record_task_metadata = true

    namespace :check do
      desc 'Ensure public/map-marker files exist. (Needed for Google maps)'
      task :main_mapmarker_files do

        on release_roles :all do |host|
          target_markers_path = mapmarker_main_path
          source_files = mapmarker_main_files

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


    desc 'Create sym links to public/map-markers files if needed'
    task create_mapmarker_symlinks: ["deploy:set_rails_env", "check:main_mapmarker_files"] do

      on release_roles :all do |_host|

        target_markers_path = mapmarker_main_path
        source_files = mapmarker_main_files

        #  Note that the links are RELATIVE paths.  This makes testing on a local dev machine easier.
        mapmarker_linked_paths.each do |markerlinked_dir|
          # create the dir and any intermediate dirs only if it doesn't exist
          execute :mkdir, "-p", markerlinked_dir
          # FileUtils.mkdir_p(markerlinked_dir)

          relative_target_path = target_markers_path.relative_path_from(markerlinked_dir)

          source_files.each do |source_fname|
            linked_file = markerlinked_dir.join(source_fname)

            unless test("[ -l #{linked_file} ]")
              # unless File.symlink?(linked_file)
              execute :rm, linked_file if test "[ -f #{linked_file} ]"
              # File.delete(linked_file) if File.exist?(linked_file)

              execute :ln, "-s", "#{relative_target_path}/#{source_fname}", linked_file
              # File.symlink "#{relative_target_path}/#{source_fname}", "#{linked_file}"
            end
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
        info 'Restarting...'
        execute :touch, release_path.join('tmp/restart.txt')
      end
    end


    # Note: another way to accomplish this would be to put an entry in .gitattributes for every file to ignore.
    # However, I don't like mixing deployment information into git files.  (That couples the two systems and mixes responsibilities.)
    desc 'Remove testing related files'
    task :remove_test_files do

      on release_roles :all do

        # Because gems for these are not deployed,
        # Rake cannot load these files,
        # which then causes problems when trying to run any rake tasks on the deployment server.
        remove_files = ["#{current_path}/lib/tasks/ci.rake",
                        "#{current_path}/lib/tasks/cucumber.rake",
                        "#{current_path}/script/cucumber"].freeze

        remove_files.each { |remove_f| remove_file remove_f }


        # Remove testing directories since the gems for using them are not deployed.
        remove_dirs = ["#{current_path}/spec",
                       "#{current_path}/features"].freeze
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
              puts "\n>> WARNING! No task named #{task_name_to_run}. #{info_if_missing}\n\n"
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
        warn "File doesn't exist, so it could not be removed: #{full_fn_path}" # log and puts
      end
    end


    def remove_dir(full_dir_path)
      if test("[ -d #{full_dir_path} ]") # if the directory exists on the remote server
        execute %{rm -r #{full_dir_path} }
      else
        warn "Directory doesn't exist, so it could not be removed: #{full_dir_path}" # log and puts
      end
    end


    def task_is_defined?(task_name)
      puts "( checking to see if #{task_name} is defined )"
      result = %x{bundle exec rake --tasks #{task_name} }
      result.include?(task_name) ? true : false
    end

  end

  desc 'refresh sitemaps'
  task sitemap_refresh: ["deploy:set_rails_env"] do |this_task|
    run_task_from(this_task, 'sitemap:refresh', 'Unable to refresh the SITEMAPs (/public/sitemap.* ...)')
  end

end


# ----------------------------------------------------
# Task sequencing:
# ----------------------------------------------------

# Run the task :create_mapmarker_symlinks before the (capistrano defined) deploy:check:linked_files task is run
#   so that the Mapmarker files and symlinks definitely exist.
before "deploy:check:linked_files", "shf:deploy:create_mapmarker_symlinks"

before "deploy:publishing", "shf:deploy:run_load_conditions"
after "shf:deploy:run_load_conditions", "shf:deploy:run_one_time_tasks"

# Have to wait until all files are copied and symlinked before trying to remove
#   these files.  (They won't exist until then.)
before "deploy:restart", "shf:deploy:remove_test_files"

after "deploy:publishing", "deploy:restart"

# Refresh the sitemaps
after "deploy:restart", "shf:sitemap_refresh"


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
    user   = server.user
    port   = server.port || 22

    exec "ssh -l #{user} #{host} -p #{port} -t 'cd #{deploy_to}/current && #{command}'"
  end
end
