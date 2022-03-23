require 'spec_helper'

lib_dir = File.join(__dir__, '..', '..', '..', 'lib',)

require_relative File.join(lib_dir, 'one_time_tasker', 'evaluated_rake_file')
require_relative File.join(lib_dir, 'one_time_tasker', 'evaluated_rake_task')


RSpec.describe OneTimeTasker::EvaluatedRakeFile do

  describe 'Unit tests' do

    let(:dt_2019_06_14_010101) { DateTime.new(2019, 06, 14, 01, 01, 01) }
    let(:dt_2019_06_14_020101) { DateTime.new(2019, 06, 14, 02, 01, 01) }

    let(:task1_name) { 'task1' }
    let(:task1_source) { 'task1 source'}

    let(:task1) do
      t1 = described_class.new(task1_name, task1_source)
      add_hardcoded_previous_runs(t1)
      add_hardcoded_duplicates(t1)
      t1
    end


    describe 'add_eval_task_named' do

      it 'adds a new EvaluatedRakeTask to our list of all tasks' do
        expect(subject.all_tasks).to be_empty

        subject.add_eval_task_named('blorf')
        after_all_tasks = subject.all_tasks

        expect(after_all_tasks.size).to eq(1)
        new_task = after_all_tasks.first

        expect(new_task == OneTimeTasker::EvaluatedRakeTask.new('blorf', subject.filename)).to be_truthy
      end

      it 'returns the new EvaluatedRakeTask' do
        expect(subject.add_eval_task_named('blorf') == OneTimeTasker::EvaluatedRakeTask.new('blorf', subject.filename)).to be_truthy
      end
    end


    describe 'add_task_names' do

      it 'adds nothing if the list of task names to add is empty' do
        expect { subject.add_task_names([]) }.not_to change(subject, :total_number_of_tasks)
      end

      describe 'we do not have any EvaluatedRakeTask for any of these task names' do

        it 'adds a new EvalutedRakeTask to our list of all tasks for all of the task names' do
          expect(subject.total_number_of_tasks).to eq 0

          new_tasks = %w(task1 task2)

          expect { subject.add_task_names(new_tasks) }.to change(subject, :total_number_of_tasks).by(2)

          expect(subject.all_tasks.map(&:name)).to match_array(new_tasks)
          expect(subject.all_tasks.first).to be_a OneTimeTasker::EvaluatedRakeTask
          expect(subject.all_tasks.last).to be_a OneTimeTasker::EvaluatedRakeTask
        end
      end

      describe 'we have an EvaluatedRakeTask for some of the task names' do

        it 'only adds a New EvalutedRake Task to our list of all tasks for those we do not have' do

          subject.add_eval_task_named('already_has_task')
          expect(subject.total_number_of_tasks).to eq 1

          new_tasks = %w(task1 task2 already_has_task)

          expect { subject.add_task_names(new_tasks) }.to change(subject, :total_number_of_tasks).by(2)

          expect(subject.all_tasks.map(&:name)).to match_array(new_tasks)
          expect(subject.all_tasks.first).to be_a OneTimeTasker::EvaluatedRakeTask
          expect(subject.all_tasks.last).to be_a OneTimeTasker::EvaluatedRakeTask
        end
      end
    end

  end

end
