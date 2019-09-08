require_relative 'evaluated_rake_task'
require_relative 'evaluated_rake_file'

require_relative 'log_creator'
require_relative 'activity_log_tags'


module OneTimeTasker

  #--------------------------
  #
  # @class EvaluatedTasksStateUpdater
  #
  # @desc Responsibility: Change the state of EvaluatedTasks and log the changes.
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-06-11
  #
  #--------------------------
  class EvaluatedTasksStateUpdater


    include LogCreator
    include ActivityLogTags

    TASK_ALREADY_RAN_MSG = 'Task has already been successfully run on '
    DUPLICATE_TASK_MSG = 'This task is a duplicate: more than 1 task to be run has this task name. This task cannot be run.'

    # These 2 constants are used in ActivityLogTags methods:
    DEFAULT_LOG_FACILITY_TAG = self.name unless defined?(OneTimeTasker::TasksRunner::DEFAULT_LOG_FACILITY_TAG)
    DEFAULT_LOG_ACTIVITY_TAG = 'Find One Time Tasks' unless defined?(OneTimeTasker::TasksRunner::DEFAULT_LOG_ACTIVITY_TAG)


    # ==========================================================================

    def initialize(given_log = nil, logging: true)
      set_or_create_log(given_log, logging: logging,
                        log_facility_tag: self.log_facility_tag,
                        log_activity_tag: self.log_activity_tag)
    end


    # Set the given task as a duplicate and log.
    # In the list of tasks that have this same name,
    # find all  tasks that are duplicate of this one and set them as having this duplicate.
    #
    # @return [EvaluatedTask] - the task that has been updated to have duplicates
    #
    def set_and_log_task_as_duplicate(duplicated_task, tasks_with_same_name)

      dup_filname = duplicated_task.filename

      # Get all of the other tasks that have this task name and set them as being a duplicate of this one
      the_other_dup_tasks = tasks_with_same_name.reject { |other_task| other_task == duplicated_task }
      # set these other tasks as having this one as a duplicate
      the_other_dup_tasks.each { |other_task| other_task.add_duplicate(dup_filname) }

      log_as_duplicate(duplicated_task)

      duplicated_task
    end


    # @return EvaluatedTask - the evaluated task that has been updated to not that it has already beeen run
    def set_and_log_task_as_already_ran(evaluated_task, successful_attempt)
      successful_source = successful_attempt.task_source
      successful_date = successful_attempt.attempted_on

      evaluated_task.add_previous_run(successful_source, successful_date)

      log_already_ran(evaluated_task, successful_attempt)

      evaluated_task
    end


    def log_already_ran(task, successful_attempt)
      log.error(task_already_ran_log_entry(task, successful_attempt))
    end


    def log_as_duplicate(duplicated_task)
      log.error(duplicate_task_log_entry(duplicated_task))
    end


    def task_already_ran_log_entry(task, successful_attempt)
      "Task Already Ran: Task named '#{task.name}' in the file #{task.filename}: #{TASK_ALREADY_RAN_MSG} #{successful_attempt.attempted_on} from source: #{successful_attempt.task_source}"
    end


    def duplicate_task_log_entry(duplicated_task)
      "Duplicate task name! Task named '#{duplicated_task.name}' in the file #{duplicated_task.filename}: #{DUPLICATE_TASK_MSG}"
    end


  end

end

