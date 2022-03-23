require 'rails_helper'

require 'shared_context/activity_logger'

# ===========================================================================
#  shared examples

RSpec.shared_examples 'it creates an ActivityLogger log' do

  it 'creates the ActivityLogger log instance' do
    activity_log
    expect(File).to exist(streamname)
    expect(activity_log).to be_an_instance_of(ActivityLogger)
  end

end

RSpec.shared_examples 'it returns an ActivityLogger' do
  it 'an ActivityLogger is returned' do
    log_returned = ActivityLogger.open(logfilepath, 'TEST', 'open', false) do |_log|
      expect(File).to exist(logfilepath)
    end
    expect(log_returned).to be_a ActivityLogger
  end
end


# ===========================================================================

RSpec.describe ActivityLogger do

  include_context 'create logger'

  let(:test_message_body) { 'this is a test message' }
  let(:test_message_regex) { /\[TEST\] \[open\] \[info\] \[(.*)\] this is a test message/ }

  describe 'log file' do

    before(:each) do
      File.delete(logfilepath) if File.file?(logfilepath)
    end


    describe '.open' do

      it_behaves_like 'it creates an ActivityLogger log' do
        let(:streamname) { logfilepath }
        let(:activity_log) { log }
      end

      it 'logs "Started at <timestamp>" with the INFO severity before the message to log' do
        expect_any_instance_of(ActiveSupport::Logger).to receive(:info).with(/Started at/)
        expect_any_instance_of(ActiveSupport::Logger).to receive(:info).with( anything ) # the message logged

        log.info(test_message_body)
      end

      it 'logs the message' do
        expect_any_instance_of(ActiveSupport::Logger).to receive(:info) # Started at... with(anything).
        expect_any_instance_of(ActiveSupport::Logger).to receive(:info).with( test_message_body)

        log.info(test_message_body)
      end

      it_behaves_like 'it returns an ActivityLogger'


      context 'pass in a block' do

        it 'creates log file' do
          ActivityLogger.open(logfilepath, 'TEST', 'open', false) do |_log|
            expect(File).to exist(logfilepath)
          end
        end

        it 'the log in the block is an instance of ActivityLogger' do
          ActivityLogger.open(logfilepath, 'TEST', 'open', false) do |log|
            expect(log).to be_an_instance_of(ActivityLogger)
          end
        end

        it_behaves_like 'it returns an ActivityLogger'

        it 'records the message to the log, surrounded with Started at..  and Finished... Duration...' do
          expect_any_instance_of(ActiveSupport::Logger).to receive(:info).with(/Started at/).once
          expect_any_instance_of(ActiveSupport::Logger).to receive(:warn).with( test_message_body).once
          expect_any_instance_of(ActiveSupport::Logger).to receive(:info).with(/Finished/).once
          expect_any_instance_of(ActiveSupport::Logger).to receive(:info).with(/Duration/).once

          ActivityLogger.open(logfilepath, 'TEST', 'open', false) do |log|
            log.warn(test_message_body)
          end
        end

      end # context 'open with a block'

    end


    context 'directory does not exist' do

      it 'can create a writeable directory and the log in it' do

        nonexistent_dirname = Dir::Tmpname.create(SPEC_LOGDIR_PREFIX) { |dirname| dirname }
        log_file = File.join(nonexistent_dirname, SPEC_LOGNAME)

        expect(File.exist? nonexistent_dirname).to be_falsey

        log = ActivityLogger.open(log_file, 'TEST', 'open', false)
        log.close

        # dir was created
        expect(File.exist?(nonexistent_dirname)).to be_truthy
        expect(File.writable?(nonexistent_dirname)).to be_truthy

        # log was created
        expect(File).to exist(log_file)

      end

      it '(SAD PATH) cannot create directory, raises IOError' do

        cant_create_dirname = Dir::Tmpname.create(SPEC_LOGDIR_PREFIX) { |dirname| dirname }
        file_in_problem_dir = File.join(cant_create_dirname, SPEC_LOGNAME)

        expect(File.exist?(cant_create_dirname)).to be_falsey

        allow(Dir).to receive(:mkdir).and_raise(IOError)

        expect { ActivityLogger.open(file_in_problem_dir, 'TEST', 'open', false) }.
            to raise_error(IOError, 'Could not make log directory.')

      end

      it '(SAD PATH) cannot create a writeable directory, raises ActivityLoggerDirNotWritable' do

        dir_not_writeable = Dir::Tmpname.create(SPEC_LOGDIR_PREFIX) { |dirname| dirname }
        file_in_unwriteable_dir = File.join(dir_not_writeable, SPEC_LOGNAME)

        expect(File.exist?(dir_not_writeable)).to be_falsey

        original_mkdir = Dir.method(:mkdir)

        allow(Dir).to receive(:mkdir) do
          original_mkdir.call(dir_not_writeable)
          File.chmod(0444, dir_not_writeable) # make it read only
          dir_not_writeable
        end

        expect { ActivityLogger.open(file_in_unwriteable_dir, 'TEST', 'open', false) }.
            to raise_error ActivityLoggerDirNotWritable
      end


    end # context log directory does not exist


    it 'directory is read only, raises ActivityLoggerDirNotWritable (SAD PATH)' do

      readonly_dir = Dir.mktmpdir(SPEC_LOGDIR_PREFIX)
      File.chmod(0444, readonly_dir) # make it read only

      log_in_unwritable_dir = File.join(readonly_dir, SPEC_LOGNAME)

      expect(File.exist? readonly_dir).to be_truthy
      expect(File.writable? readonly_dir).to be_falsey

      expect { ActivityLogger.open(log_in_unwritable_dir, 'TEST', 'open', false) }.
          to raise_error ActivityLoggerDirNotWritable
    end


  end #  describe 'log file'


  context 'using stdout or stderr as the log' do
    # Odd, but we must handle it

    context "using $stderr as the log" do

      context 'open without a block' do

        it_behaves_like 'it creates an ActivityLogger log' do
          let(:streamname) { $stderr }
          let(:activity_log) { ActivityLogger.open(streamname, 'TEST', 'open', false) }
        end

        it "records message to $stderr" do
          expect do
            logstream = $stderr
            log = ActivityLogger.open(logstream, 'TEST', 'open', false)
            log # to open it
            log.record('info', 'this is a test message to stderr')
          end.to output(/\[TEST\] \[open\] \[info\] \[(.*)\] this is a test message to stderr/).to_stderr
        end

        # If the stream is closed, the OS will throw errors the next time *any process* tries to write to the stream
        it "doesn't close the stream" do
          logstream = $stderr
          log = ActivityLogger.open(logstream, 'TEST', 'open', false)
          log # to open it
          log.record('info', 'this is a test message to stderr again')
          log.close
          expect($stderr.closed?).to be_falsey
        end

      end # context 'open without a block'

      context 'open with a block' do

        let(:streamname) { $stderr }
        let(:activity_log) { ActivityLogger.open(streamname, 'TEST', 'open', false) }

        it 'creates log file' do
          ActivityLogger.open(streamname, 'TEST', 'open', false) do |_log|
            expect(File).to exist(streamname)
          end
        end

        it 'returns instance of ActivityLogger' do
          ActivityLogger.open(streamname, 'TEST', 'open', false) do |log|
            expect(log).to be_an_instance_of(ActivityLogger)
          end
        end

        it "records message to $stderr" do
          expect do
            logstream = $stderr
            ActivityLogger.open(logstream, 'TEST', 'open', false) do |log|
              log # to open it
              log.record('info', 'this is another test message to stderr')
            end
          end.to output(/\[TEST\] \[open\] \[info\] \[(.*)\] this is another test message to stderr/).to_stderr
        end

      end # context 'open with a block'

    end # context 'using $stderr as the log'


    context "using $stdout as the log" do

      context 'open without a block' do

        it_behaves_like 'it creates an ActivityLogger log' do
          let(:streamname) { $stdout }
          let(:activity_log) { ActivityLogger.open(streamname, 'TEST', 'open', false) }
        end

        it "records message to $stdout" do
          expect do
            logstream = $stdout
            log = ActivityLogger.open(logstream, 'TEST', 'open', false)
            log # to open it
            log.record('info', 'this is a test message to stdout')
          end.to output(/\[TEST\] \[open\] \[info\] \[(.*)\] this is a test message to stdout/).to_stdout
        end

        # If the stream is closed, the OS will throw errors the next time *any process* tries to write to the stream
        it "doesn't close the stream" do
          logstream = $stdout
          log = ActivityLogger.open(logstream, 'TEST', 'open', false)
          log # to open it
          log.record('info', 'this is a test message to stdout again')
          log.close
          expect($stdout.closed?).to be_falsey
        end

      end # context 'open without a block'

      context 'open with a block' do

        let(:streamname) { $stdout }
        let(:activity_log) { ActivityLogger.open(streamname, 'TEST', 'open', false) }

        it 'creates log file' do
          ActivityLogger.open(streamname, 'TEST', 'open', false) do |_log|
            expect(File).to exist(streamname)
          end
        end

        it 'returns instance of ActivityLogger' do
          ActivityLogger.open(streamname, 'TEST', 'open', false) do |log|
            expect(log).to be_an_instance_of(ActivityLogger)
          end
        end

        it "records message to $stdout" do
          expect do
            logstream = $stdout
            ActivityLogger.open(logstream, 'TEST', 'open', false) do |log|
              log # to open it
              log.record('info', 'this is another test message to stdout')
            end
          end.to output(/\[TEST\] \[open\] \[info\] \[(.*)\] this is another test message to stdout/).to_stdout
        end

      end # context 'open with a block'

    end # context 'using $stdout as the log'

  end # context 'using stdout or stderr as the log' do


  describe 'record' do

    it 'raises InvalidLogSeverityLevell if a severity level is not allowed' do
      expect { log.record('blorf', 'bad severity level') }.to raise_exception InvalidLogSeverityLevel
    end

    it 'logs the message with the given severity' do
      # Note: if you use log.record('debug', 'something') and expect_any_instance...
      #  you may also have to account for the ActiveRecord connection logger writing out DEBUG statements during testing.

      #once with the Started...message,  once with the message we send below
      expect_any_instance_of(Logger).to receive(:info).with(anything).twice
      expect_any_instance_of(Logger).to receive(:warn).with('blorf').once
      expect_any_instance_of(Logger).to receive(:fatal).with('uh oh!').once

      log.record('info', 'hello')
      log.record('warn', 'blorf')
      log.record('fatal', 'uh oh!')
    end

    it 'adds a timestamp (as one of the tags)' do
      mock_logger = instance_double("ActiveSupport::TaggedLogging")
      allow(ActiveSupport::TaggedLogging).to receive(:new).and_return(mock_logger)

      expect(mock_logger).to receive(:tagged)
                                 .with("TEST", "open", "info",
                                       /(.*)/)
                                 .twice
      # twice because the tagged log receives it once to open the log and once for the 'log.record(...)' sent

      log.record('info', test_message_body)
    end
  end


  it '#info records the a message with severity= info' do
    expect(log).to receive(:record).with('info', 'hello')
    log.info('hello')
  end


  it '#warn records the a message with severity= warn' do
    expect(log).to receive(:record).with('warn', 'hello')
    log.warn('hello')
  end


  it '#debug records the a message with severity= debug' do
    expect(log).to receive(:record).with('debug', 'hello')
    log.debug('hello')
  end


  it '#error records the a message with severity= error' do
    expect(log).to receive(:record).with('error', 'hello')
    log.error('hello')
  end


  it '#fatal records the a message with severity= fatal' do
    expect(log).to receive(:record).with('fatal', 'hello')
    log.fatal('hello')
  end


  it '#unknown records the a message with severity= unknown' do
    expect(log).to receive(:record).with('unknown', 'hello')
    log.unknown('hello')
  end

end
