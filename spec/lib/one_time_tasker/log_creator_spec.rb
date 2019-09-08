require 'rails_helper'  # LogCreator counts on being able to find ActivityLogger and LogfileNamer

require_relative File.join(__dir__, '..', '..', '..', 'lib', 'one_time_tasker', 'log_creator')


class TestLogCreator
  extend LogCreator
end

RSpec.describe LogCreator do

  let(:subject) { TestLogCreator }
  let(:created_logfilename) { ::LogfileNamer.name_for(subject) }

  before(:each) do
    logfilename = LogfileNamer.name_for(subject)
    File.delete(logfilename) if File.exist?(logfilename)
  end

  after(:each) do
    logfilename = LogfileNamer.name_for(subject)
    File.delete(logfilename) if File.exist?(logfilename)
  end

  describe '.set_or_create_log' do

    context 'the given log is not nil' do

      # This is probably some kind of Log in real life. This is sufficient for unit testing
      given_log = 'blorf'

      before(:each) do
        expect(subject).not_to receive(:make_log)
        subject.set_or_create_log(given_log)
      end

      context 'logging == true' do

        it 'uses the given log' do
          expect(subject.log).to eq given_log
        end

        # TODO shared test:
        it 'writes to the given log' do

          logfile_name = LogfileNamer.name_for('tasks_runner_spec')
          File.delete(logfile_name) if File.exist?(logfile_name)

          given_log = ActivityLogger.open(logfile_name,
                                          'TaskRunner Spec',
                                          'Given log is used')
          subject.set_or_create_log(given_log)
          given_log.close

          file_contents = File.exist?(logfile_name) ? File.read(logfile_name) : 'log file for task_runner_spec does not exist'
          expect(file_contents).to include('[TaskRunner Spec] [Given log is used] [info] Started at')
          File.delete(logfile_name) if File.exist?(logfile_name)
        end

        it 'this_created_the_log is false' do
          expect(subject.this_created_the_log).to be_falsey
        end
      end

      context 'logging == false' do
        it 'uses the given log' do
          expect(subject.log).to eq given_log
        end

        it 'this_created_the_log is false' do
          expect(subject.this_created_the_log).to be_falsey
        end
      end
    end


    context 'the given log is nil (none is given)' do

      context 'logging == true' do

        it 'creates an ActivityLogger' do
          expect(subject).to receive(:make_log).and_call_original
          subject.set_or_create_log
          expect(subject.log).to be_a(ActivityLogger)
        end

        it 'this_created_the_log is true' do
          subject.set_or_create_log
          expect(subject.this_created_the_log).to be_truthy
        end

        it 'log file name is the LogfileNamer.name_for this class' do
          expect(ActivityLogger).to receive(:open).with(LogfileNamer.name_for(subject), anything, anything)
          subject.set_or_create_log
        end


        it 'a log is created if none is given' do
          # ensure none exists so that we verify what we want to verify
          expect(File.exist?(created_logfilename)).to be_falsey

          subject.set_or_create_log
          expect(File.exist?(created_logfilename)).to be_truthy
        end

        it 'writes to the created log' do

          subject.set_or_create_log
          created_log = subject.log
          created_log.close

          file_contents = File.exist?(created_logfilename) ? File.read(created_logfilename) : 'log file for task_runner_spec does not exist'
          expect(file_contents).to include('[info] Started at')
          File.delete(created_logfilename) if File.exist?(created_logfilename)
        end

        describe 'ActivityLogger facility tag' do

          it 'default is an empty String' do
            expect(ActivityLogger).to receive(:open).with(anything, '', anything)
            subject.set_or_create_log
          end

          it 'can be passed in and set' do
            expect(ActivityLogger).to receive(:open).with(anything, 'custom facility tag', anything)
            subject.set_or_create_log(nil, log_facility_tag: 'custom facility tag')
          end
        end

        describe 'ActivityLogger activity tag' do

          it 'default is an empty String' do
            expect(ActivityLogger).to receive(:open).with(anything, anything, '')
            subject.set_or_create_log
          end

          it 'can be passed in and set' do
            expect(ActivityLogger).to receive(:open).with(anything, anything, 'custom activity tag')
            subject.set_or_create_log(nil, log_activity_tag: 'custom activity tag')
          end

        end
      end


      context 'logging == false' do

        it 'creates the NoLogger' do
          subject.set_or_create_log(logging: false)
          expect(subject.log).to eq(LogCreator::NoLogger)
        end

        it 'this_created_the_log is true' do
          subject.set_or_create_log(logging: false)
          expect(subject.this_created_the_log).to be_truthy
        end

        it 'logging: false = nothing is written to a log' do
          # ensure none exists so that we verify what we want to verify
          expect(File.exist?(LogfileNamer.name_for(subject))).to be_falsey

          expect(ActivityLogger).not_to receive(:open).with(LogfileNamer.name_for(subject), anything, anything)
          subject.set_or_create_log(logging: false)
          expect(File.exist?(LogfileNamer.name_for(subject))).to be_falsey
        end

      end
    end

  end


  describe '.close_log_if_this_created_it' do

    let(:no_logger_log) { LogCreator::NoLogger }


    context 'log is not nil' do
      context 'this created the log' do

        it 'calls log.close' do
          allow(subject).to receive(:this_created_the_log).and_return(true)
          allow(subject).to receive(:log).and_return(no_logger_log)

          expect(no_logger_log).to receive(:close)
          subject.close_log_if_this_created_it(no_logger_log)
        end

      end

      context 'this did not create the log' do

        it 'does not call log.close' do
          allow(subject).to receive(:this_created_the_log).and_return(false)
          allow(subject).to receive(:log).and_return(no_logger_log)

          expect(no_logger_log).not_to receive(:close)
          subject.close_log_if_this_created_it(no_logger_log)
        end
      end
    end

    context 'log is nil' do

      context 'this created the log' do
        it 'does not call log.close' do
          allow(subject).to receive(:this_created_the_log).and_return(true)
          allow(subject).to receive(:log).and_return(nil)

          orig_rspec_mocks_nil_expect = RSpec::Mocks.configuration.allow_message_expectations_on_nil
          RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
          expect(nil).not_to receive(:close)
          subject.close_log_if_this_created_it(no_logger_log)
          RSpec::Mocks.configuration.allow_message_expectations_on_nil = orig_rspec_mocks_nil_expect
        end
      end

      context 'this did not create the log' do
        it 'does not call log.close' do
          allow(subject).to receive(:this_created_the_log).and_return(false)
          allow(subject).to receive(:log).and_return(nil)

          orig_rspec_mocks_nil_expect = RSpec::Mocks.configuration.allow_message_expectations_on_nil
          RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
          expect(nil).not_to receive(:close)
          subject.close_log_if_this_created_it(no_logger_log)
          RSpec::Mocks.configuration.allow_message_expectations_on_nil = orig_rspec_mocks_nil_expect
        end
      end
    end

  end


  it '.this_created_the_log is false by default' do
    expect(subject.this_created_the_log).to be_falsey
  end

end

