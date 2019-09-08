module OneTimeTasker

  #--------------------------
  #
  # @class EvaluatedRakeFile
  #
  # @desc Responsibility: Provides additional information about a .rake file
  # and its tasks: total number of tasks and a list of tasks in it.
  # Used by  OneTimeTasker::TasksRunner to process a .rake file.
  # This is a very simple class
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-06-10
  #
  #
  #--------------------------
  class EvaluatedRakeFile

    attr_accessor :filename, :tasks_to_run
    attr_writer :all_tasks


    def initialize(filename = '', task_names: [], tasks_to_run: [])
      @filename = filename
      @all_tasks = []
      task_names.each { |task_name| add_eval_task_named(task_name) }
      @tasks_to_run = tasks_to_run
    end


    # All tasks in this .rake file
    def all_tasks
      @all_tasks ||= []
    end


    # Add a new EvaluatedRakeTask for any task_names that we don't already
    # have in our list of all tasks
    #
    # @return Array[EvaluatedRakeTasks]- all tasks
    #
    def add_task_names(task_names)
      return if task_names.empty?

      missing_task_names = task_names - all_tasks.map(&:name)

      missing_task_names.each { |task_name| add_eval_task_named(task_name) }

      all_tasks
    end


    # Add a new EvaluatedRakeTask to our list of tasks
    #
    # @return [EvaluatedRakeTask] -  the new EvaluatedRakeTask
    def add_eval_task_named(task_name)
      new_ev_task = EvaluatedRakeTask.new(task_name, self.filename)
      add_eval_task(new_ev_task)

      new_ev_task
    end


    # Add an evaluated task to our list of all tasks
    def add_eval_task(ev_task)
      self.all_tasks << ev_task
    end


    def total_number_of_tasks
      self.all_tasks.size
    end


  end

end
