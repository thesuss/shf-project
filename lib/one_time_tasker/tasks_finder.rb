require_relative 'evaluated_rake_task'
require_relative 'evaluated_rake_file'
require_relative 'evaluated_tasks_state_updater'

require_relative 'log_creator'
require_relative 'activity_log_tags'


module OneTimeTasker

  #--------------------------
  #
  # @class TasksFinder
  #
  # @desc Responsibility: Get all 'one time' rake tasks that should be run.
  #   As it evaluates tasks to see if they should be run, it works with the
  #   TaskManager to set task state and log things.
  #
  #   Log errors for any of these conditions
  #   and do not include them in the list of tasks that should be run:
  #    1. a task has already been successfully run
  #    2. tasks with the same name are going to be run, even if they have never been run
  #      ( = duplicates)
  #
  #   Get all one time rake tasks that should be run:
  #     This will look for all .rake task files in the :tasks_directory and then get
  #     all tasks in them.
  #     A task should be run if and only if
  #       there is _not_ a OneTimeTasker::SuccessfulTaskAttempt with the same task name
  #
  #   Log an error if a task has already been run or duplicate task names are found.
  #     If there are tasks with the same name _and_ they all should be run
  #       Ex:
  #         subdir_A/rake_file_1.rake  has a task named 'shf:task_a'
  #         subdir_B/rake_file_1.rake  has a task named 'shf:task_a'
  #         subdir_B/rake_file_2.rake  has a task named 'shf:task_a'
  #
  #
  #   Because this never attempts to run (invoke) Rake tasks,
  #   it does not ever record a TaskAttempt.
  #
  #
  # TODO: I18n locale file for string constants, log entries
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-05-21
  #
  #--------------------------
  class TasksFinder

    include LogCreator
    include ActivityLogTags


    DEFAULT_ONE_TIME_TASKS_DIR = File.join(__dir__, '..', '..', 'lib', 'tasks', 'one_time') unless defined?(DEFAULT_ONE_TIME_TASKS_DIR)

    # These 2 constants are used in ActivityLogTags methods:
    DEFAULT_LOG_FACILITY_TAG = self.name unless defined?(OneTimeTasker::TasksRunner::DEFAULT_LOG_FACILITY_TAG)
    DEFAULT_LOG_ACTIVITY_TAG = 'Find One Time Tasks' unless defined?(OneTimeTasker::TasksRunner::DEFAULT_LOG_ACTIVITY_TAG)


    # tasks_directory -- The directory where the TasksFinder will look for .rake files.
    #                    It will search in this directory and all subdirectories.
    #                    The getter (read) method uses lazy initialization
    attr_writer :tasks_directory

    # tasks_updater -- The updater that will set tasks as duplicates and/or
    #                    as having been already run.
    attr_reader :tasks_updater


    # ==========================================================================


    def initialize(given_log = nil, logging: false)

      set_or_create_log(given_log, logging: logging,
                        log_facility_tag: self.log_facility_tag,
                        log_activity_tag: self.log_activity_tag)

      @tasks_updater = OneTimeTasker::EvaluatedTasksStateUpdater.new(given_log, logging: logging)

    end

    def tasks_directory
      @tasks_directory ||=  File.absolute_path(DEFAULT_ONE_TIME_TASKS_DIR)
    end


    # Get all tasks in all rake files that should be run,
    # then remove any duplicates.
    #
    # This is the main method to run.
    #
    # @return [Hash] - the rake files and their tasks that should be run
    #   key = the full path to a rake file
    #   value = list of the tasks in the rake file that should be run
    #
    def files_with_tasks_to_run

      # load all tasks into self.all_tasks
      get_tasks_from_rakefiles

      set_and_log_tasks_already_ran(self.all_tasks)
      set_and_log_duplicate_tasks(self.all_tasks_not_previously_run)

      close_log_if_this_created_it(log)

      rakefiles_with_tasks_to_run

    rescue => error
      log.error("Error during #{self.class.name}  #{__method__}!  #{error}") unless log.nil?
      raise error
    end


    # Get all tasks from the tasks_directory. Return a list of EvaluatedTasks
    #
    # @return Array[EvaluatedTasks] - list of EvaluatedTasks based on all of the
    #                                 Rake::Tasks read in
    #
    def get_tasks_from_rakefiles

      # ensure we're starting out with no tasks or rakefiles
      clear_all_tasks_and_rakefiles

      rakefiles_to_read = onetime_rake_files

      return [] if rakefiles_to_read.empty?

      rakefiles_to_read.each(&method(:get_tasks_in_rakefile))

      self.all_tasks
    end


    # Return a Hash of only the rakefiles that have tasks to be run.
    # key = rakefile name, value = EvaluatedRakeFile
    #
    # Add the tasks to run for each EvaluatedRakeFile
    def rakefiles_with_tasks_to_run

      rakefiles_with_tasks = new_hash_of_eval_rakefiles

      # This isn't efficient, but it's clear:
      all_tasks_to_run.each do |task_to_run|
        rakefilename = task_to_run.filename
        ev_rakefile_to_run = self.all_rakefiles[rakefilename]
        ev_rakefile_to_run.tasks_to_run << task_to_run
        rakefiles_with_tasks[rakefilename] = ev_rakefile_to_run
      end

      rakefiles_with_tasks
    end


    # If there are tasks with the same name, mark them as duplicates
    # and log them.
    #
    # @param evaluated_tasks Array[EvaluatedTask] - tasks to work with
    # @return Array[EvaluatedTask] - all tasks marked as duplicates
    #
    def set_and_log_duplicate_tasks(evaluated_tasks)

      return [] if evaluated_tasks.empty?

      # get all of the task_names that are duplicates (TODO ruby 2.7: replace this with .tally)
      duplicated_names = evaluated_tasks.group_by(&:name).select { |_name, tasks | tasks.size > 1 }.keys

      # Guard condition: no duplicate names, so just return
      return [] if duplicated_names.empty?

      # get the duplicated tasks for each name; return all of them
      duplicated_names.map{|dup_name| duplicated_tasks_for_name(dup_name, evaluated_tasks) }.flatten
    end


    # @param [Array[String]] duplicated_names - all task names that are duplicated
    # @param [Array[EvaluatedTasks]] ev_tasks - tasks to search in for duplicates
    #
    # @return Array[EvaluatedTasks]] - list of all tasks that are duplicates
    def duplicated_tasks_for_name(duplicated_name, ev_tasks)

      tasks_with_same_name = ev_tasks.select { |task| task.name == duplicated_name }

      # Set each task as a duplicate; return the list of duplicate tasks
     tasks_with_same_name.map{| task | tasks_updater.set_and_log_task_as_duplicate(task, tasks_with_same_name) }
    end


    # Determine the tasks that have already run successfully in this rakefile
    #
    # @param [Array[EvaluatedRakeTask]] evaluated_tasks -  tasks to go through and find those already successfully run
    # @return Array[EvaluatedRakeTask] - tasks that have already been successfully run
    #
    def set_and_log_tasks_already_ran(evaluated_tasks)
      return [] if evaluated_tasks.empty?

      already_ran = []

      evaluated_tasks.each do |evaluated_task|
        successful_attempt = find_successful_attempt_for_task(evaluated_task)
        already_ran << tasks_updater.set_and_log_task_as_already_ran(evaluated_task, successful_attempt) if successful_attempt
      end

      already_ran
    end


    # @return Hash - a new hash such that if an entry for a key does not exist,
    #   then a new entry is made, with the value = a new EvaluatedRakefile
    #    with the filename for the new EvaluatedRakeFile == the key
    def new_hash_of_eval_rakefiles
      Hash.new { |hash, key| hash[key] = EvaluatedRakeFile.new(key) }
    end


    # Note how the Hash is created:
    #  If an entry for a key ( = rake file name) does not exist,
    #   then a new entry is made, with the value = EvaluatedRakefile(key).new
    def all_rakefiles
      @all_rakefiles ||= new_hash_of_eval_rakefiles
    end


    def all_tasks
      @all_tasks ||= []
    end


    def clear_all_tasks_and_rakefiles
      @all_rakefiles = nil
      @all_tasks = nil
    end


    # Return all of the tasks that should be run:
    # No duplicates, no tasks that have previously been run successfully.
    def all_tasks_to_run
      self.all_tasks - all_tasks_previously_run - all_tasks_duplicates
    end


    def all_tasks_previously_run
      self.all_tasks.select { |task| task.already_run? }
    end


    def all_tasks_not_previously_run
      self.all_tasks.reject { |task| task.already_run? }
    end


    def all_tasks_not_duplicates
      self.all_tasks.reject { |task| task.duplicate? }
    end


    def all_tasks_duplicates
      self.all_tasks.select { |task| task.duplicate? }
    end


    # All .rake files in the onetime_tasks_path
    def onetime_rake_files
      tasks_dir = self.tasks_directory
      return [] unless Dir.exist?(tasks_dir) && !Dir.empty?(tasks_dir)

      Dir.glob(File.join('**', '*.rake'), base: tasks_dir)
    end


    # Add a new EvaluatedRakeFile for the rakefilename if we don't already have
    # it.
    # Add all task names to the EvalutedRakeFile that it doesn't already have.
    #
    # @return EvalutedRakeFile - the EvaluatedRakeFile for this rakefilename
    def add_rakefile_and_tasks(rakefilename, task_names)

      # creates a new EvaluatedRakeFile entry if needed
      ev_rakefile = self.all_rakefiles[rakefilename]
      ev_rakefile.add_task_names(task_names)
      self.all_tasks.concat(ev_rakefile.all_tasks)

      ev_rakefile
    end


    # Don't cache (memoize) these.  We always want the latest info from the db.
    def successful_task_attempts
      OneTimeTasker::SuccessfulTaskAttempt.all
    end



    # --------------------------------------------------------------------------


    private


    def get_tasks_in_rakefile(rakefile)
      full_rakefile_path = File.absolute_path(File.join(self.tasks_directory, rakefile))

      # Get the Rake::Tasks in the rakefiles.
      # This will not load or return tasks already loaded or global tasks.
      onetime_rake_tasks = Rake.with_application do
        Rake.load_rakefile(full_rakefile_path)
      end

      rake_task_names = onetime_rake_tasks.tasks.map(&:name)
      add_rakefile_and_tasks(full_rakefile_path, rake_task_names)
    end


    # Find a SuccessfulAttempt for the EvaluatedTask.
    # if a SuccessfulAttempt is found, return the first one found.
    #   else return nil if none found
    #
    # @return [nil | OneTimeTasker::SuccessfulTaskAttempt]
    #
    def find_successful_attempt_for_task(evaluated_task)
      self.successful_task_attempts.detect { |already_ran_task| already_ran_task.task_name == evaluated_task.name }
    end


  end

end
