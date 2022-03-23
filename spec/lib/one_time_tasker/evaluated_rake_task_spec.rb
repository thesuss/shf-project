require 'spec_helper'

lib_dir = File.join(__dir__, '..', '..', '..', 'lib',)
require_relative File.join(lib_dir, 'one_time_tasker', 'evaluated_rake_task')


RSpec.describe OneTimeTasker::EvaluatedRakeTask do

  describe 'Unit tests' do

    let(:dt_2019_06_14_010101) { DateTime.new(2019, 06, 14, 01, 01, 01) }
    let(:dt_2019_06_14_020101) { DateTime.new(2019, 06, 14, 02, 01, 01) }

    let(:task1_name) { 'task1' }
    let(:task1_source) { 'task1 source'}

    # add these hardcoded previous runs to the task so we can ensure exact duplicates
    def add_hardcoded_previous_runs(task)
      task.add_previous_run('t1 previous run 1', dt_2019_06_14_010101)
      task.add_previous_run('t1 previous run 2', dt_2019_06_14_020101)
    end

    # add these hardcoded duplicates to the task so we can ensure exact duplicates
    def add_hardcoded_duplicates(task)
      task.add_duplicate('t1 duplicate 1')
      task.add_duplicate('t1 duplicate 2')
    end

    let(:task1) do
      t1 = described_class.new(task1_name, task1_source)
      add_hardcoded_previous_runs(t1)
      add_hardcoded_duplicates(t1)
      t1
    end

    describe 'duplicate? (is this a duplidate?)' do

      it 'true if this has any duplicates' do
        expect(task1.duplicate?).to be_truthy
      end

      it 'false if it has no duplicates' do
        task1.duplicates.clear
        expect(task1.duplicate?).to be_falsey
      end
    end

    describe 'already_run?' do

      it 'true if this has any previous successful runs' do
        expect(task1.already_run?).to be_truthy
      end

      it 'false if it has no previous successful runs' do
        task1.previous_successful_runs.clear
        expect(task1.already_run?).to be_falsey
      end
    end

    describe 'add_previous_run' do

      it 'adds to the list of previous successful runs for the task' do
        expect(task1.previous_successful_runs.map(&:source)).not_to include('blorf source')
        task1.add_previous_run('blorf source', DateTime.now)
        expect(task1.previous_successful_runs.map(&:source)).to include('blorf source')
      end

      it 'no duplicates allowed: cannot add a run with the same name and time' do
        expect(task1.previous_successful_runs.map(&:source)).not_to include('blorf source')
        task1.add_previous_run('blorf source', dt_2019_06_14_010101)
        task1.add_previous_run('blorf source', dt_2019_06_14_010101)
        expect(task1.previous_successful_runs.map(&:source).count('blorf source')).to eq 1
      end
    end

    describe 'add_duplicate' do

      it 'adds to the list of duplicates for the task' do
         expect(task1.duplicates.map(&:source)).not_to include('blorf source')
         task1.add_duplicate('blorf source')
         expect(task1.duplicates.map(&:source)).to include('blorf source')
      end

      it 'can have duplicates: can add a duplicate with the same source as another one' do
        expect(task1.duplicates.map(&:source)).not_to include('blorf source')
        task1.add_duplicate('blorf source')
        task1.add_duplicate('blorf source')
        expect(task1.duplicates.map(&:source).count('blorf source')).to eq 2
      end

    end


    describe '==' do

      # Return a new instance to work with
      def create_task1_duplicate
        dup = described_class.new(task1_name, task1_source)
        add_hardcoded_previous_runs(dup)
        add_hardcoded_duplicates(dup)
        dup
      end

      let(:task1_duplicate) do
       create_task1_duplicate
      end


      it 'false if filenames are different' do
        task1_duplicate.filename = 'different filename'
        expect(task1 == task1_duplicate).to be_falsey
      end

      it 'false if names are different' do
        task1_duplicate.name = 'different name'
        expect(task1 == task1_duplicate).to be_falsey
      end

      it 'false if duplicates are different in any way' do
        has_additional_dup = create_task1_duplicate
        has_additional_dup.add_duplicate('another duplicate')
        expect(task1 == has_additional_dup).to be_falsey

        has_fewer_dups = create_task1_duplicate
        has_fewer_dups.duplicates.pop
        expect(task1 == has_fewer_dups).to be_falsey

        dup_with_different_name = create_task1_duplicate
        dup_with_different_name.duplicates.last.source = 'different source'
        expect(task1 == dup_with_different_name).to be_falsey
      end

      it 'false if previous successful runs are different' do
        has_additional_prev_run = create_task1_duplicate
        has_additional_prev_run.add_previous_run('t1 previous run 3', dt_2019_06_14_010101)
        expect(task1 == has_additional_prev_run).to be_falsey

        has_fewer_prev_runs = create_task1_duplicate
        has_fewer_prev_runs.previous_successful_runs.delete_if{|prev_run| prev_run.source == 't1 previous run 2'}
        expect(task1 == has_fewer_prev_runs).to be_falsey

        prev_run_with_different_name = create_task1_duplicate
        prevs_arr = prev_run_with_different_name.previous_successful_runs.to_a
        prevs_arr.last.source = 'different source'
        prev_run_with_different_name.previous_successful_runs.clear
        prevs_arr.each { | prev_run| prev_run_with_different_name.add_previous_run(prev_run.source, prev_run.when_ran) }
        expect(task1 == prev_run_with_different_name).to be_falsey

        prev_run_with_different_time = create_task1_duplicate
        prevs_arr = prev_run_with_different_time.previous_successful_runs.to_a
        prevs_arr.last.when_ran = DateTime.now
        prev_run_with_different_time.previous_successful_runs.clear
        prevs_arr.each { | prev_run| prev_run_with_different_time.add_previous_run(prev_run.source, prev_run.when_ran) }
        expect(task1 == prev_run_with_different_time).to be_falsey
      end

      it 'true if filenames, names, duplicates, AND previous successful runs are all ==' do
        expect(task1 == task1_duplicate).to be_truthy
      end
    end


  end

end
