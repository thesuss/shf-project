# @description Configuration information for the OneTimeTasker::TasksRunner
#
# @file config/initializers/one_time_tasks_runner.rb

if defined?(OneTimeTasker::TasksRunner)

  OneTimeTasker::TasksRunner.configure do |config|

    # This string is appended to each .rake filename
    # if all of the tasks in the rake file ran successfully.
    # Appending this to the filename helps to keep the rake file
    # from being run again.
    #
    # Default is '.ran'
    config.successful_rakefile_extension = '.ran'

    # This is the directory where all .rake files should be for
    # the Rake::Tasks to be run once.
    # This directory can contain subdirectories; all subdirectories will be
    # searched for all .rake files (uses glob **/*.rake)
    #
    # Default is:  File.join(Rails.root, 'lib', 'tasks', 'one_time')
    config.tasks_directory = File.join(Rails.root, 'lib', 'tasks', 'one_time')

  end

end
