# Tasks to run to deploy the application.  Tasks defined here can be called by capistrano.

require_relative '../one_time_tasker/tasks_runner'
require 'active_support/logger'


namespace :shf do

  namespace :one_time do


    desc 'Create example task files for OneTimeTasker::TasksRunner. Directory will be deleted and then created.'
    task :create_example_files, [:rakefile_dir] => [:environment] do |_taskname, args|

      default_rakefile_dir = File.join(FileUtils.pwd, 'my_onetime_tasks')

      usage = "USAGE: rails shf:one_time:create_example_files[directory/where/rake_files/will_be/created]\n" +
          "        default directory = './my_onetime_tasks' Used if no directory is given \n" +
          "        Directory(-ies) will be created if they don't exist.\n"

      base_dir = default_rakefile_dir

      if args.has_key? :rakefile_dir
        given_dir = File.join(FileUtils.pwd, args[:rakefile_dir])

        unless Dir.exist?(given_dir)
          begin
            FileUtils.mkdir_p(given_dir)

          rescue => mkdir_error
            puts "\nError while trying to make the directory #{given_dir}\n   #{mkdir_error}\n\n#{usage}\n"
            raise mkdir_error
          end
        end

        base_dir = given_dir
      end

      create_rake_files(base_dir)
      puts "\nExample 'one time' rake files have been created under #{base_dir}\n"
    end
  end


  # one_task.rake
  #   one_task  # task will run
  #
  # another_task.rake
  #   another_task  # task will run
  #
  # my_tasks_all_mine.rake
  #   mine:task1  # task will run
  #   mine:task2  # task has a duplicate (will not run)
  #   mine:task3  # task has a duplicate (will not run)
  #   mine:task4  # task will run
  #
  # other_tasks_run_all.rake
  #    other_task1_run_me  # task will run
  #    other_task2_run_me  # task has a duplicate (will not run)
  #    other_task3_run_me  # task has a duplicate (will not run)
  #    other_task_not_run_yet  # task will run
  #
  # other_tasks_mixed_duplicates.rake
  #    other_task2_run_me  # task has a duplicate (will not run)
  #    other_task3_run_me  # task has a duplicate (will not run)
  #
  # task2_duplicate.rake
  #   mine:task2  # task has a duplicate (will not run)
  #
  # task4_duplicate.rake
  #   mine:task4  # task has a duplicate (will not run)
  #
  def create_rake_files(base_dir)

    one_task_fn = File.join(base_dir, 'one_task.rake')
    make_tasks_in_file(['one_task'], one_task_fn) if ok_to_create?(one_task_fn)

    another_task_fn = File.join(base_dir, 'another_task.rake')
    make_tasks_in_file(['another_task'], another_task_fn) if ok_to_create?(another_task_fn)

    my_tasks_mine_fn = File.join(base_dir, 'my_tasks_all_mine.rake')
    make_tasks_in_file(['task1', 'task2', 'task3', 'task4'], my_tasks_mine_fn, namespace: 'mine') if ok_to_create?(my_tasks_mine_fn)

    tasks_run_all_fn = File.join(base_dir, 'other_tasks_run_all.rake')
    make_tasks_in_file(['other_task1_run_me', 'other_task2_run_me', 'other_task3_run_me', 'other_task_not_run_yet'], tasks_run_all_fn) if ok_to_create?(tasks_run_all_fn)

    tasks_mixed_duplicates_fn = File.join(base_dir, 'other_tasks_mixed_duplicates.rake')
    make_tasks_in_file(['other_task2_run_me', 'other_task3_run_me'], tasks_mixed_duplicates_fn) if ok_to_create?(tasks_mixed_duplicates_fn)

    task2_duplicate_fn = File.join(base_dir, 'task2_duplicate.rake')
    make_tasks_in_file(['task2'], task2_duplicate_fn, namespace: 'mine') if ok_to_create?(task2_duplicate_fn)

    task4_duplicate_fn = File.join(base_dir, 'task4_duplicate.rake')
    make_tasks_in_file(['task4'], task4_duplicate_fn, namespace: 'mine') if ok_to_create?(task4_duplicate_fn)
  end


  # If the file exists, ask if it's ok to overwrite. return true only if they said it was ok to overwrite.
  # If the file does not exist, return true (it's ok to create it)
  # @return Boolean
  def ok_to_create?(filepath)
    File.exist?(filepath) ? prompt_to_overwrite?(filepath) : true
  end


  def prompt_to_overwrite?(filepath)
    print "#{filepath} already exists.  Overwrite it? [Y/n]: "
    answer = STDIN.gets.chomp
    answer == 'Y'
  end


  # Make rake tasks for  of the tasks in tasknames, in the file named filepath.
  # Makes all directories needed for the filepath if they don't already exist.
  #
  def make_tasks_in_file(tasknames = [], filepath = '.', task_body = "\n", namespace: '')

    indent = ""
    filedir = File.dirname(filepath)
    FileUtils.mkdir_p(filedir) unless Dir.exist?(filedir)

    File.open(filepath, 'w') do |f|
      unless namespace.empty?
        indent = "  "
        f.puts namespace_start(namespace)
      end

      tasknames.each do |taskname|
        f.puts simple_rake_task(taskname, indent: indent, task_body: task_body)
      end

      f.puts namespace_end unless namespace.empty?
    end
    filepath
  end


  # Code for a simple task.
  # The body of the task is given :task_body
  #
  # @param task_name [String] - the task name
  # @param task_body [String] - the code for task. This is what will be run.
  #
  def simple_rake_task(task_name = 'test_task', indent: '', task_body: "\n")
    "\n" + indent +
        "desc 'task named #{task_name}'\n" +
        indent + "task :#{task_name} do\n" +
        indent + "  " + task_body +
        indent + "end\n\n"

  end


  def namespace_start(namespace)
    "namespace :#{namespace} do\n"
  end


  def namespace_end
    "end\n"
  end

end
