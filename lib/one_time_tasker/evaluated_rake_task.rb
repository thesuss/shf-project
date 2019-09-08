module OneTimeTasker

  #--------------------------
  #
  # @class EvaluatedRakeTask
  #
  # @desc Responsibility: Updates the state of tasks:
  # needed by OneTimeTaskder::TasksRunner:
  # whether they are duplicates or have been previously successfully run.
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-06-10
  #
  #--------------------------
  class EvaluatedRakeTask

    attr_accessor :name, :filename, :duplicates, :previous_successful_runs

    # Simple info needed to track information about any previous run for a task.
    PreviousRun = Struct.new(:source, :when_ran)

    # Simple info needed to track information a task that is a duplicate of this one.
    # Because the task names are the same ( = the definition of a 'duplicate'), this
    # is the only othe information we need to track.
    DuplicateTask = Struct.new(:source)


    def initialize(name = '', filename = '')
      @name = name
      @filename = filename
      @duplicates = []
      @previous_successful_runs = Set.new
    end


    def duplicate?
      !duplicates.empty?
    end


    def already_run?
      !previous_successful_runs.empty?
    end


    def add_previous_run(other_source, when_ran)
      previous_successful_runs << PreviousRun.new(other_source, when_ran)
    end


    def add_duplicate(other_source)
      duplicates << DuplicateTask.new(other_source)
    end


    # Two EvaluatedRakeTasks are == if:
    # 1. their rakefiles are ==
    # 2. their task names are ==
    # 3. their list of duplicates are == (same size, each element ==)
    # 4. their list of previous_successful_runts are == (szme size, each element ==)
    #
    # @return Boolean
    def ==(other_ev_rake_task)
      self.filename == other_ev_rake_task.filename &&
          self.name == other_ev_rake_task.name &&
          self.duplicates == other_ev_rake_task.duplicates &&
          self.previous_successful_runs == other_ev_rake_task.previous_successful_runs
    end

  end

end
