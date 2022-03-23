require_relative 'simple_rake_task_files_maker'

#
# Methods and definitions for creating a set of many task files with tasks in each.
#
RSpec.shared_context 'many task files' do

  include_context 'simple rake task files maker'

  #
  # Directory and File names
  #
  Q1_DIR = '2019_Q1' unless defined?(Q1_DIR)
  Q2_DIR = '2019_Q2' unless defined?(Q2_DIR)
  BLORF_DIR = 'blorf' unless defined?(BLORF_DIR)
  BLORF2_DIR = 'blorf2' unless defined?(BLORF2_DIR)

  RAKEFILENAME = 'test.rake' unless defined?(RAKEFILENAME)

  # tasks that are duplicates or have already been run are in the _2_ files
  FORMAT_CITYNAMES_RAKEFILE = 'format_city_names.rake' unless defined?(FORMAT_CITYNAMES_RAKEFILE)

  SET_WHEN_APPR_RAKEFILE = 'set_when_approved.rake' unless defined?(SET_WHEN_APPR_RAKEFILE)
  SET_WHEN_APPR2_RAKEFILE = 'set_when_approved2.rake' unless defined?(SET_WHEN_APPR2_RAKEFILE)
  GOOD_TASK_RAKEFILE = 'good_task.rake' unless defined?(GOOD_TASK_RAKEFILE)
  GOOD_TASK2_RAKEFILE = 'good_task2.rake' unless defined?(GOOD_TASK2_RAKEFILE)
  SIMPLE_TASK_RAKEFILE = 'simple_task.rake' unless defined?(SIMPLE_TASK_RAKEFILE)
  SIMPLE_AND_SOME5_RAKEFILE = 'simple_and_some5.rake' unless defined?(SIMPLE_AND_SOME5_RAKEFILE)

  SOME_TASKS_RAKEFILE = 'some_tasks.rake' unless defined?(SOME_TASKS_RAKEFILE)
  SOMETASK1_RAKEFILE = 'sometask1.rake' unless defined?(SOMETASK1_RAKEFILE)

  RUN_THIS_RAKEFILE = 'run_this_task.rake' unless defined?(RUN_THIS_RAKEFILE)

  #
  # Task names
  #
  SET_WHEN_APPROVED_TASK = 'set_when_approved_data' unless defined?(SET_WHEN_APPROVED_TASK)
  GOODTASK = 'good_task' unless defined?(GOODTASK)
  FORMAT_CITYNAMES_TASK = 'format_city_names' unless defined?(FORMAT_CITYNAMES_TASK)
  SIMPLETASK = 'simple_task' unless defined?(SIMPLETASK)
  SOMETASK1 = 'some_task_1' unless defined?(SOMETASK1)
  SOMETASK2 = 'some_task_2' unless defined?(SOMETASK2)
  SOMETASK3 = 'some_task_3' unless defined?(SOMETASK3)
  SOMETASK4 = 'some_task_4' unless defined?(SOMETASK4)
  SOMETASK5 = 'some_task_5' unless defined?(SOMETASK5)
  RUNTHISTASK = 'run_this_task' unless defined?(RUNTHISTASK)

  TASK_SCOPE = 'shf:test' unless defined?(TASK_SCOPE)

  SET_WHEN_APPROVED_SCOPED = "#{TASK_SCOPE}:#{SET_WHEN_APPROVED_TASK}" unless defined?(SET_WHEN_APPROVED_SCOPED)
  GOODTASK_SCOPED = "#{TASK_SCOPE}:#{GOODTASK}" unless defined?(GOODTASK_SCOPED)
  FORMAT_CITY_NAMES_SCOPED = "#{TASK_SCOPE}:#{FORMAT_CITYNAMES_TASK}" unless defined?(FORMAT_CITY_NAMES_SCOPED)
  SIMPLETASK_SCOPED = 'simple_task' unless defined?(SIMPLETASK_SCOPED) unless defined?(SIMPLETASK_SCOPED)

  SOMETASK1_SCOPED = "#{TASK_SCOPE}:#{SOMETASK1}" unless defined?(SOMETASK1_SCOPED)
  SOMETASK2_SCOPED = "#{TASK_SCOPE}:#{SOMETASK2}" unless defined?(SOMETASK2_SCOPED)
  SOMETASK3_SCOPED = "#{TASK_SCOPE}:#{SOMETASK3}" unless defined?(SOMETASK3_SCOPED)
  SOMETASK4_SCOPED = "#{TASK_SCOPE}:#{SOMETASK4}" unless defined?(SOMETASK4_SCOPED)
  SOMETASK5_SCOPED = "#{TASK_SCOPE}:#{SOMETASK5}" unless defined?(SOMETASK5_SCOPED)


  # Make task files in the directory given
  def make_many_task_files(given_dir)

    # already_ran_approved = File.join(q1_dir(given_dir), "#{SET_WHEN_APPR_RAKEFILE}.ran")
    # make_tasks_in_file(tasknames = [SET_WHEN_APPROVED_TASK], already_ran_approved)

    q1_sometasks = File.join(q1_dir(given_dir), SOME_TASKS_RAKEFILE)
    make_tasks_in_file([SOMETASK1, SOMETASK2, SOMETASK3, SOMETASK4, SOMETASK5], q1_sometasks)


    already_ran_city_names = File.join(q2_dir(given_dir), "#{FORMAT_CITYNAMES_RAKEFILE}.ran")
    make_tasks_in_file([FORMAT_CITYNAMES_TASK], already_ran_city_names)

    already_ran_q2_goodtask = File.join(q2_dir(given_dir), "#{GOOD_TASK_RAKEFILE}.ran")
    make_tasks_in_file([GOODTASK], already_ran_q2_goodtask)


    blorf_goodtask = File.join(blorf_dir(given_dir), GOOD_TASK2_RAKEFILE)
    make_tasks_in_file([GOODTASK], blorf_goodtask)

    blorf_already_ran_approved = File.join(blorf_dir(given_dir), SET_WHEN_APPR2_RAKEFILE)
    make_tasks_in_file([SET_WHEN_APPROVED_TASK], blorf_already_ran_approved)

    blorf_simpletask = File.join(blorf_dir(given_dir), SIMPLE_TASK_RAKEFILE)
    make_tasks_in_file([SIMPLETASK], blorf_simpletask)

    already_ran_blorf_sometask1 = File.join(blorf_dir(given_dir), "#{SOMETASK1_RAKEFILE}.ran")
    make_tasks_in_file([SOMETASK1], already_ran_blorf_sometask1)


    already_ran_blorf2_task1 = File.join(blorf2_dir(given_dir), "#{SOMETASK1_RAKEFILE}.ran")
    make_tasks_in_file([SOMETASK1], already_ran_blorf2_task1)

    blorf2_approved = File.join(blorf2_dir(given_dir), SET_WHEN_APPR_RAKEFILE)
    make_tasks_in_file([SET_WHEN_APPROVED_TASK], blorf2_approved)

    blorf2_simple_task5 = File.join(blorf2_dir(given_dir), SIMPLE_AND_SOME5_RAKEFILE)
    make_tasks_in_file([SIMPLETASK, SOMETASK5], blorf2_simple_task5)

    toplevel_simpletask = File.join(given_dir, SIMPLE_TASK_RAKEFILE)
    make_tasks_in_file([SIMPLETASK], toplevel_simpletask)

    toplevel_run_this = File.join(given_dir, RUN_THIS_RAKEFILE)
    make_tasks_in_file([RUNTHISTASK], toplevel_run_this)
  end


  # Do a quick and dirty list of the files and Rake tasks in given_dir
  def list_files_and_tasks(given_dir)
    puts "\nList of files and tasks in: #{given_dir}"
    puts "  Note: this includes all files with 'rake' _anywhere_ in the extension so that it will show *.rake.run and more: Dir.glob(File.join('**', *.rake*')\n\n"
    files = Dir.glob(File.join("**", "*.rake*"), base: given_dir)

    Rake.with_application do

      files.each do |filename|
        puts " #{filename}"
        full_rakefile_path = File.absolute_path(File.join(given_dir, filename))

        begin
          onetime_rake_tasks = Rake.with_application do
            Rake.load_rakefile(full_rakefile_path)
          end
          rake_task_names = onetime_rake_tasks.tasks.map(&:name)

          rake_task_names.each do |taskname|
            puts "   #{taskname}"
          end

        rescue => e
          puts "  - this file doesn't seem to be a Rakefile.  Error with Rake.load_rakefile()"
          puts e
        end

        puts "\n"
      end
    end

    puts "\n"
  end


  def q1_dir(given_dir)
    File.absolute_path(File.join(given_dir, Q1_DIR))
  end


  def q2_dir(given_dir)
    File.absolute_path(File.join(given_dir, Q2_DIR))
  end


  def blorf_dir(given_dir)
    File.absolute_path(File.join(given_dir, BLORF_DIR))
  end


  def blorf2_dir(given_dir)
    File.absolute_path(File.join(given_dir, BLORF2_DIR))
  end


  def scoped(task_name)
    "#{TASK_SCOPE}:#{task_name}"
  end


  # Create 5 successful and 1 unsuccessful task attempts
  def create_5_successful_task_attempts(base_directory)
    create(:one_time_tasker_task_attempt, :successful_task,
           task_name: SET_WHEN_APPROVED_SCOPED,
           task_source: File.join(base_directory, Q1_DIR, SET_WHEN_APPR_RAKEFILE))

    create(:one_time_tasker_task_attempt, :successful_task,
           task_name: SOMETASK2_SCOPED,
           task_source: File.join(base_directory, Q1_DIR, SOME_TASKS_RAKEFILE))
    create(:one_time_tasker_task_attempt, :successful_task,
           task_name: SOMETASK3_SCOPED,
           task_source: File.join(base_directory, Q1_DIR, SOME_TASKS_RAKEFILE))

    create(:one_time_tasker_task_attempt, :successful_task,
           task_name: GOODTASK_SCOPED,
           task_source: File.join(base_directory, Q2_DIR, GOOD_TASK_RAKEFILE))
    create(:one_time_tasker_task_attempt, :successful_task,
           task_name: FORMAT_CITY_NAMES_SCOPED,
           task_source: File.join(base_directory, Q2_DIR, FORMAT_CITYNAMES_RAKEFILE))

    # unsuccessful task:
    create(:one_time_tasker_task_attempt, :unsuccessful_task,
           task_name: SOMETASK4_SCOPED,
           task_source: File.join(base_directory, Q1_DIR, SOME_TASKS_RAKEFILE))
  end


  # The array of EvaluatedTasks from the rakefiles created in
  # the make_many_task_files method
  def all_evaluated_tasks_in_files(given_dir)
    eval_tasks = []

    [SOMETASK1, SOMETASK2, SOMETASK3, SOMETASK4, SOMETASK5].each do |sometask|
      eval_tasks << OneTimeTasker::EvaluatedRakeTask.new(scoped(sometask), File.join(q1_dir(given_dir), SOME_TASKS_RAKEFILE))
    end

    eval_tasks << OneTimeTasker::EvaluatedRakeTask.new(scoped(GOODTASK), File.join(blorf_dir(given_dir), GOOD_TASK2_RAKEFILE))
    eval_tasks << OneTimeTasker::EvaluatedRakeTask.new(scoped(SET_WHEN_APPROVED_TASK), File.join(blorf_dir(given_dir), SET_WHEN_APPR2_RAKEFILE))
    eval_tasks << OneTimeTasker::EvaluatedRakeTask.new(scoped(SIMPLETASK), File.join(blorf_dir(given_dir), SIMPLE_TASK_RAKEFILE))

    eval_tasks << OneTimeTasker::EvaluatedRakeTask.new(scoped(SET_WHEN_APPROVED_TASK), File.join(blorf2_dir(given_dir), SET_WHEN_APPR_RAKEFILE))

    [SIMPLETASK, SOMETASK5].each do |blorf2_simplemore_task|
      eval_tasks << OneTimeTasker::EvaluatedRakeTask.new(scoped(blorf2_simplemore_task), File.join(blorf2_dir(given_dir), SIMPLE_AND_SOME5_RAKEFILE))
    end

    eval_tasks << OneTimeTasker::EvaluatedRakeTask.new(scoped(SIMPLETASK), File.join(given_dir, SIMPLE_TASK_RAKEFILE))
    eval_tasks << OneTimeTasker::EvaluatedRakeTask.new(scoped(RUNTHISTASK), File.join(given_dir, RUN_THIS_RAKEFILE))

    eval_tasks
  end

end

# ------------------------------------------------------------------------------
