require 'rails_helper'

require 'shared_examples/shared_condition_specs'
require 'shared_context/activity_logger'

# TODO mock logs with a FakeLogger + use 'expect(FakeLogger).to receive(...)' (= faster since no file I/O)


RSpec.describe Backup, type: :model do

  before(:each) do
    @logfilename = LogfileNamer.name_for(Condition)
    File.delete(@logfilename) if File.exist?(@logfilename)

    # stub actually sending Slack notifications
    allow(SHFNotifySlack).to receive(:notification)
  end

  after(:each) do
    File.delete(@logfilename) if File.exist?(@logfilename)
  end



  describe 'Acceptance tests' do

    include_context 'create logger'

    before(:each) do

      @faux_app_dir = Dir.mktmpdir('faux-app-dir')

      # set up files to be backed up: make 2 notes files:
      @notes_filenames = []
      2.times do |i|
        @notes_filenames[i] = File.join(@faux_app_dir, "notes-#{i}.txt")
        File.open(@notes_filenames[i], 'w') do |f|
          f.puts "notes #{i}"
        end
      end
      @notes_sources = [@notes_filenames]

      # create a faux code directory to be backed up
      @code_dir = Dir.mktmpdir('faux-code')
      @code_filenames = []
      3.times do |i|
        @code_filenames[i] = "faux_code#{i}.rb"
        File.open(File.join(@code_dir, @code_filenames[i]), 'w') do |f|
          f.puts "class FauxCode-#{i};  end"
        end
      end
      @code_sources = [@code_dir]

      # db to be backed up
      @db_to_backup = 'shf_project_test'
      @db_sources = [@db_to_backup]

      allow_any_instance_of(CodeBackupMaker).to receive(:default_sources)
                                                    .and_return(@code_sources)
      allow_any_instance_of(DBBackupMaker).to receive(:default_sources)
                                                  .and_return(@db_sources)
      allow_any_instance_of(FilesBackupMaker).to receive(:default_sources)
                                                     .and_return(@notes_sources)
      # destination for the backup files
      @backup_dir = Dir.mktmpdir('backup-dir')
    end


    let(:backup_condition) do
      condition_info = { class_name: 'Backup',
                         timing: :every_day,
                         config: { days_to_keep: { code_backup: 2,
                                                   db_backup: 5,
                                                   files_backup: 31 },
                                   backup_directory: @backup_dir,
                                   files: @notes_sources } }

      Condition.new(condition_info)
    end

    let(:yy_mm_dd_timestr) { Time.now.strftime '%Y-%m-%d' }
    let(:expected_aws_bucketname) { "production_backup/#{yy_mm_dd_timestr}/" }

    let(:code_backup_basefn) { 'current.tar' }
    let(:code_backup_fname) { "#{code_backup_basefn}.#{yy_mm_dd_timestr}.gz" }

    let(:db_backup_basefn) { 'db_backup.sql' }
    let(:db_backup_fname) { "#{db_backup_basefn}.#{yy_mm_dd_timestr}.gz" }

    let(:files_backup_basefn) { 'backup-FilesBackupMaker.tar' }
    let(:files_backup_fname) { "#{files_backup_basefn}.#{yy_mm_dd_timestr}.gz" }


    it 'does the backup - everything works (HAPPY PATH)' do

      expect(described_class).to receive(:upload_file_to_s3)
                                     .with(anything, anything, expected_aws_bucketname, File.join(@backup_dir, code_backup_fname))
      expect(described_class).to receive(:upload_file_to_s3)
                                     .with(anything, anything, expected_aws_bucketname, File.join(@backup_dir, db_backup_fname))
      expect(described_class).to receive(:upload_file_to_s3)
                                     .with(anything, anything, expected_aws_bucketname, File.join(@backup_dir, files_backup_fname))

      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{File.join(@backup_dir, code_backup_basefn)}.*", 2)
      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{File.join(@backup_dir, db_backup_basefn)}.*", 5)
      expect(described_class).to receive(:delete_excess_backup_files)
                                     .with("#{File.join(@backup_dir, files_backup_basefn)}.*", 31)

      class_name = backup_condition.class_name
      klass = class_name.constantize

      ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
        log.info("#{class_name} ...")
        klass.condition_response(backup_condition, log)
      end

      # no errors in the log file
      expect(File.read(@logfilename)).not_to include('error')

      # expect the backup files to be in the backup directory
      expect(File.exist?(File.join(@backup_dir, code_backup_fname))).to be_truthy
      expect(File.exist?(File.join(@backup_dir, db_backup_fname))).to be_truthy
      expect(File.exist?(File.join(@backup_dir, files_backup_fname))).to be_truthy
    end


    describe 'errors happen - 1 error should not stop the entire backup' do

      it 'one of the shell commands for the DBBackupMaker fails' do

        allow_any_instance_of(DBBackupMaker).to receive(:shell_cmd)
                                                    .with(/touch/)
                                                    .and_raise(Errno::ENOENT, 'blorfo')

        expect(described_class).to receive(:upload_file_to_s3)
                                       .with(anything, anything, expected_aws_bucketname, File.join(@backup_dir, code_backup_fname))
        expect(described_class).to receive(:upload_file_to_s3)
                                       .with(anything, anything, expected_aws_bucketname, File.join(@backup_dir, db_backup_fname))
        expect(described_class).to receive(:upload_file_to_s3)
                                       .with(anything, anything, expected_aws_bucketname, File.join(@backup_dir, files_backup_fname))

        expect(described_class).to receive(:delete_excess_backup_files)
                                       .with("#{File.join(@backup_dir, code_backup_basefn)}.*", 2)
        expect(described_class).to receive(:delete_excess_backup_files)
                                       .with("#{File.join(@backup_dir, db_backup_basefn)}.*", 5)
        expect(described_class).to receive(:delete_excess_backup_files)
                                       .with("#{File.join(@backup_dir, files_backup_basefn)}.*", 31)

        expected_error_text = /No such file or directory - blorfo while in the backup_makers.each loop. Current item:/
        # Slack notification should be sent
        expect(SHFNotifySlack).to receive(:failure_notification)
                                      .with('Backup', text: expected_error_text)
                                 #     .with('Backup', text: 'No such file or directory - blorfo')


        class_name = backup_condition.class_name
        klass = class_name.constantize

        ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
          log.info("#{class_name} ...")
          klass.condition_response(backup_condition, log)
        end

        # There will be errors in the log file
        expect(File.read(@logfilename)).to match(expected_error_text)

        # expect only the successful backup files to be in the backup directory
        expect(File.exist?(File.join(@backup_dir, code_backup_fname))).to be_truthy
        expect(File.exist?(File.join(@backup_dir, db_backup_fname))).to be_falsey
        expect(File.exist?(File.join(@backup_dir, files_backup_fname))).to be_truthy
      end


      it 'writing to AWS fails for the code backup file' do
        @error_raised = NoMethodError.new('flurb')

        allow(described_class).to receive(:upload_file_to_s3)
                                      .with(anything, anything, expected_aws_bucketname, File.join(@backup_dir, code_backup_fname))
                                      .and_raise(@error_raised)

        expect(described_class).to receive(:upload_file_to_s3)
                                       .with(anything, anything, expected_aws_bucketname, File.join(@backup_dir, db_backup_fname))
        expect(described_class).to receive(:upload_file_to_s3)
                                       .with(anything, anything, expected_aws_bucketname, File.join(@backup_dir, files_backup_fname))

        expect(described_class).to receive(:delete_excess_backup_files)
                                       .with("#{File.join(@backup_dir, code_backup_basefn)}.*", 2)
        expect(described_class).to receive(:delete_excess_backup_files)
                                       .with("#{File.join(@backup_dir, db_backup_basefn)}.*", 5)
        expect(described_class).to receive(:delete_excess_backup_files)
                                       .with("#{File.join(@backup_dir, files_backup_basefn)}.*", 31)

        expected_error_text = /#{@error_raised} in backup_files loop, uploading_file_to_s3. Current item:/

        # Slack notification should be sent
        expect(SHFNotifySlack).to receive(:failure_notification).with(anything, text: expected_error_text)

        class_name = backup_condition.class_name
        klass = class_name.constantize

        ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
          log.info("#{class_name} ...")
          klass.condition_response(backup_condition, log)
        end

        # There will be errors in the log file
        expect(File.read(@logfilename)).to match(expected_error_text)

        # expect the backup files to be in the backup directory
        expect(File.exist?(File.join(@backup_dir, code_backup_fname))).to be_truthy
        expect(File.exist?(File.join(@backup_dir, db_backup_fname))).to be_truthy
        expect(File.exist?(File.join(@backup_dir, files_backup_fname))).to be_truthy
      end


      it 'pruning the backup files fails' do
        @error_raised = NoMethodError

        allow(described_class).to receive(:validate_timing)
        allow_any_instance_of(AbstractBackupMaker).to receive(:backup)

        allow(described_class).to receive(:upload_file_to_s3)

        expect(described_class).to receive(:delete_excess_backup_files)
                                       .with("#{File.join(@backup_dir, code_backup_basefn)}.*", anything)
                                       .and_raise(@error_raised)

        expect(described_class).to receive(:delete_excess_backup_files)
                                       .with("#{File.join(@backup_dir, db_backup_basefn)}.*", anything)
        expect(described_class).to receive(:delete_excess_backup_files)
                                       .with("#{File.join(@backup_dir, files_backup_basefn)}.*", anything)

        expected_error_text = /#{@error_raised} while pruning in the backup_makers.each loop. Current item:/

        # Slack notification should be sent
        expect(SHFNotifySlack).to receive(:failure_notification).with(anything, text: expected_error_text)

        class_name = backup_condition.class_name
        klass = class_name.constantize

        ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
          log.info("#{class_name} ...")
          klass.condition_response(backup_condition, log)
        end

        # The error was recorded in the log
        expect(File.read(@logfilename)).to match(expected_error_text)

        # expect the backup files to be in the backup directory
        expect(File.exist?(File.join(@backup_dir, code_backup_fname))).to be_truthy
        expect(File.exist?(File.join(@backup_dir, db_backup_fname))).to be_truthy
        expect(File.exist?(File.join(@backup_dir, files_backup_fname))).to be_truthy
      end
    end


    describe 'Backup is halted if we cannot send a Slack notification for an error; error raised and message tells where the error happened' do

      before(:each) do
        @slack_error = Slack::Notifier::APIError.new
      end

      let(:start_of_error_text) { 'Slack Notification failure during Backup\.condition_response' }


      it 'not within a loop: logs "(in rescue at bottom of condition_response)"' do
        allow(described_class).to receive(:backup_dir).and_raise(@slack_error)

        allow(described_class).to receive(:validate_timing)
        allow_any_instance_of(AbstractBackupMaker).to receive(:backup)

        allow(described_class).to receive(:upload_file_to_s3)
        allow(described_class).to receive(:delete_excess_backup_files)

        class_name = backup_condition.class_name
        klass = class_name.constantize

        ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
          log.info("#{class_name} ...")
          expect{klass.condition_response(backup_condition, log)}.to raise_error(@slack_error,)
        end

        expected_error_text = /#{start_of_error_text} \(in rescue at bottom of condition_response\): #{@slack_error}/
        # The Slack error was recorded in the log
        expect(File.read(@logfilename)).to match(expected_error_text)
      end


      it 'during backup_makers .backup loop; logs "while in the backup_makers.each loop"' do
        allow(described_class).to receive(:validate_timing)

        allow_any_instance_of(FilesBackupMaker).to receive(:backup)
        allow_any_instance_of(CodeBackupMaker).to receive(:backup)
        allow_any_instance_of(DBBackupMaker).to receive(:backup).and_raise(@slack_error)

        allow(described_class).to receive(:upload_file_to_s3)
        allow(described_class).to receive(:delete_excess_backup_files)

        class_name = backup_condition.class_name
        klass = class_name.constantize

        ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
          log.info("#{class_name} ...")
          expect{klass.condition_response(backup_condition, log)}.to raise_error(@slack_error,)
        end

        expected_error_text = /#{start_of_error_text} while in the backup_makers\.each loop\. Current item:/

        # The Slack error was recorded in the log just once
        expect(File.read(@logfilename)).to match(expected_error_text)
        expect(File.read(@logfilename)).not_to match(/not within a loop/) # the error is not also logged by final rescue clause
      end


      it 'during AWS loop; logs info for the current AWS items and "in backup_files.each loop uploading_file_to_s3"' do
        allow(described_class).to receive(:validate_timing)

        allow_any_instance_of(AbstractBackupMaker).to receive(:backup)

        allow(described_class).to receive(:upload_file_to_s3).and_raise(@slack_error)

        allow(described_class).to receive(:delete_excess_backup_files)

        class_name = backup_condition.class_name
        klass = class_name.constantize

        ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
          log.info("#{class_name} ...")
          expect{klass.condition_response(backup_condition, log)}.to raise_error(@slack_error,)
        end

        expected_error_text = /#{start_of_error_text} in backup_files loop, uploading_file_to_s3\. Current item:/
        # The Slack error was recorded in the log just once
        expect(File.read(@logfilename)).to match(expected_error_text)
        expect(File.read(@logfilename)).not_to match(/not within a loop/) # the error is not also logged by final rescue clause
      end


      it 'during pruning backups loop; logs info about the backup maker and file pattern and "while pruning in the backup_makers.each loop backup_maker"' do
        allow(described_class).to receive(:validate_timing)

        allow_any_instance_of(AbstractBackupMaker).to receive(:backup)

        allow(described_class).to receive(:upload_file_to_s3)

        allow(described_class).to receive(:delete_excess_backup_files).and_raise(@slack_error)

        class_name = backup_condition.class_name
        klass = class_name.constantize

        ActivityLogger.open(@logfilename, 'SHF_TASK', 'Conditions') do |log|
          log.info("#{class_name} ...")
          expect{klass.condition_response(backup_condition, log)}.to raise_error(@slack_error,)
        end

        expected_error_text = /#{start_of_error_text} while pruning in the backup_makers\.each loop\. Current item:/

        # The Slack error was recorded in the log just once
        expect(File.read(@logfilename)).to match(expected_error_text)
        expect(File.read(@logfilename)).not_to match(/not within a loop/) # the error is not also logged by final rescue clause
      end

    end
  end


  describe 'Unit tests' do


    let(:condition) { build(:condition, timing: Backup::TIMING_EVERY_DAY) }
    let(:today) { Time.now.strftime '%Y-%m-%d' }


    let(:today_timestamp) { Backup.today_timestamp }
    let(:expected_bucket) { ENV['SHF_AWS_S3_BACKUP_BUCKET'] }
    let(:expected_bucket_folder) { "production_backup/#{today_timestamp}/" }


    def create_faux_backup_file(backups_dir, file_prefix)
      File.open(File.join(backups_dir, "#{file_prefix}-faux-backup.bak"), 'w').path
    end


    describe '.backup_dir' do

      it 'uses the backup_directory in the config' do
        backup = build(:condition, :every_day, config: { backup_directory: 'blorf-dir' })
        expect(described_class.backup_dir(backup.config)).to eq 'blorf-dir'
      end

      it 'if the dir in the config is not found, uses /home/deploy/SHF_BACKUPS/' do
        backup = build(:condition, :every_day)
        expect(described_class.backup_dir(backup.config)).to eq '/home/deploy/SHF_BACKUPS/'
      end

    end


    describe '.backup_target_fn' do

      it 'joins the given directory with the given filename, appends "." + a timestamp and .gz to the base filename' do
        timestamp = Time.now.strftime Backup::TIMESTAMP_FMT
        expect(described_class.backup_target_fn('blorf-dir', 'blorf')).to eq(File.join('blorf-dir', "blorf.#{timestamp}.gz"))
      end

    end


    describe '.get_s3_objects' do

      it 'requires ENV variables for the AWS credentials and region' do
        expect(ENV.fetch('SHF_AWS_S3_BACKUP_BUCKET', nil)).not_to be_nil
        expect(ENV.fetch('SHF_AWS_S3_BACKUP_REGION', nil)).not_to be_nil
        expect(ENV.fetch('SHF_AWS_S3_BACKUP_KEY_ID', nil)).not_to be_nil
        expect(ENV.fetch('SHF_AWS_S3_BACKUP_SECRET_ACCESS_KEY', nil)).not_to be_nil
      end

      it 'uses the argument as part of the bucket folder name' do
        result = Backup.get_s3_objects('blorfo')
        expect(result[2]).to eq "production_backup/blorfo/"
      end

      it 'uses Bucket.today_timestamp is no argument is given' do
        result = Backup.get_s3_objects
        expect(result[1]).to eq expected_bucket
        expect(result[2]).to eq expected_bucket_folder
      end

      it 'returns array of [AWS S3 credentials, bucket, bucket_folder' do
        result = Backup.get_s3_objects(today_timestamp)
        expect(result[1]).to eq expected_bucket
        expect(result[2]).to eq expected_bucket_folder
      end

    end


    it '.upload_file_to_s3 calls .upload_file for the bucket, folder, and file to upload' do

      temp_backups_dir = Dir.mktmpdir('faux-backups-dir')
      faux_backup_fn = create_faux_backup_file(temp_backups_dir, 'faux_backup.bak')

      expect_any_instance_of(Aws::S3::Object).to receive(:upload_file).with(faux_backup_fn).and_return(true)

      aws_s3_resource, bucket, bucket_folder = Backup.get_s3_objects(today_timestamp)

      Backup.upload_file_to_s3(aws_s3_resource, bucket, bucket_folder, faux_backup_fn)

      FileUtils.remove_entry(temp_backups_dir, true)
    end


    it '.delete_excess_backup_files sorts based on filename, deleting those that come first' do

      # create some faux backup files
      temp_backups_dir = Dir.mktmpdir('faux-backups-dir')
      backup_a0 = create_faux_backup_file(temp_backups_dir, 'a0')
      backup_a1 = create_faux_backup_file(temp_backups_dir, 'a1')
      backup_a2 = create_faux_backup_file(temp_backups_dir, 'a2')
      backup_a3 = create_faux_backup_file(temp_backups_dir, 'a3')

      expect(File.exist?(backup_a0)).to be_truthy
      expect(File.exist?(backup_a1)).to be_truthy
      expect(File.exist?(backup_a2)).to be_truthy
      expect(File.exist?(backup_a3)).to be_truthy

      Backup.delete_excess_backup_files("#{temp_backups_dir}/*.bak", 2)

      expect(File.exist?(backup_a0)).to be_falsey
      expect(File.exist?(backup_a1)).to be_falsey
      expect(File.exist?(backup_a2)).to be_truthy
      expect(File.exist?(backup_a3)).to be_truthy

      FileUtils.remove_entry(temp_backups_dir, true)
    end


    describe '.condition_response' do

      class FakeLogger
        def self.record(*args)
        end

        def self.error(*args)
        end
      end

      let(:backup_config) { { class_name: 'Backup',
                              timing: Backup::TIMING_EVERY_DAY,
                              days_to_keep: { code_backup: 4,
                                              db_backup: 15,
                                              files_backup: 31 },
                              backup_directory: nil,
                              files: ['file1.txt', '/some/dir'] } }

      let(:backup_condition) { build(:condition, config: backup_config, timing: Backup::TIMING_EVERY_DAY) }


      before(:each) do
        @code_backup_maker = CodeBackupMaker.new(target_filename: 'code_backup_maker_target_file.tar')
        @db_backup_maker1 = DBBackupMaker.new(target_filename: 'db_backup_maker_target_file.sql')
        @db_backup_maker2 = DBBackupMaker.new(target_filename: 'another_db_backup_maker_target_file.flurb')
        @file_backup_maker = FilesBackupMaker.new(target_filename: 'files_maker_target_file.tar',
                                                  backup_sources: ['file1.txt', 'file2.zip'])
        @created_backup_makers = [
            { backup_maker: @code_backup_maker, keep_num: 3 },
            { backup_maker: @db_backup_maker1, keep_num: 2 },
            { backup_maker: @db_backup_maker2, keep_num: 1 },
            { backup_maker: @file_backup_maker, keep_num: 99 }
        ]

        # Individual tests below might change or set an expectation
        allow_any_instance_of(AbstractBackupMaker).to receive(:shell_cmd)

        allow(described_class).to receive(:backup_dir)
                                      .and_return('BACKUP_DIR')
        allow(described_class).to receive(:create_backup_makers)
                                      .and_return(@created_backup_makers)

        # allow(described_class).to receive(:backup_target_fn)
        #                               .and_return(%w(BACKUP_DIR/code_backup_maker_target_file.zzz BACKUP_DIR/db_backup_maker_target_file.sql BACKUP_DIR/another_db_backup_maker_target_file.flurb BACKUP_DIR/files_maker_target_file.tar))

        allow(described_class).to receive(:get_s3_objects)
        allow(described_class).to receive(:upload_file_to_s3)
        allow(described_class).to receive(:get_backup_files_pattern).and_call_original
        allow(described_class).to receive(:delete_excess_backup_files)
      end

      let(:expected_num_makers) { @created_backup_makers.size }



      describe '.validate_timing errors are logged and notification sent' do

        valid_timing_list = [:every_day]
        expected_list = valid_timing_list.is_a?(Enumerable) ? valid_timing_list : [valid_timing_list]

        unexpected_timings = ConditionResponder.all_timings - expected_list

        unexpected_timings.each do |unexpected_timing|

          it "logs and notififies that #{unexpected_timing} is not a valid timing but does not raise the error" do

            backup_condition.timing = unexpected_timing
            err_str          = "Received timing :#{unexpected_timing} which is not in list of expected timings: #{expected_list}"

            expect(described_class).to receive(:validate_timing).and_call_original

            # will log twice: once by ConditionResponder class, once by the Backup class. not ideal
            expect(FakeLogger).to receive(:error).with(err_str)

            expect(SHFNotifySlack).to receive(:failure_notification)
                                          .with(described_class.name, text: err_str)

            orig_on_false_positives_setting = RSpec::Expectations.configuration.on_potential_false_positives
            RSpec::Expectations.configuration.on_potential_false_positives = :nothing

            expect { described_class.condition_response(backup_condition, FakeLogger) }
                .not_to raise_exception TimingNotValidError, err_str

            RSpec::Expectations.configuration.on_potential_false_positives = orig_on_false_positives_setting
          end
        end
      end


      it 'gets the backup_dir from the configuration' do
        expect(described_class).to receive(:backup_dir).with(backup_config).and_call_original
        described_class.condition_response(backup_condition, FakeLogger)
      end

      it 'creates backup makers given a configuration' do
        expect(described_class).to receive(:create_backup_makers)
                                       .with(backup_config).and_call_original
        described_class.condition_response(backup_condition, FakeLogger)
      end

      describe 'with each backup maker, it:' do

        it 'creates the target backup filename based on the "base_name" of the backup maker' do

          expect(described_class).to receive(:backup_target_fn)
                                         .with('BACKUP_DIR', 'current.tar')
          expect(described_class).to receive(:backup_target_fn)
                                         .with('BACKUP_DIR', 'db_backup.sql')
          expect(described_class).to receive(:backup_target_fn)
                                         .with('BACKUP_DIR', 'db_backup.sql')
          expect(described_class).to receive(:backup_target_fn)
                                         .with('BACKUP_DIR', 'backup-FilesBackupMaker.tar')

          described_class.condition_response(backup_condition, FakeLogger)
        end

        it "logs a message that it is 'Backing up to: <the backup file>.<YYYY-mm-dd>.gz'" do
          allow(FakeLogger).to receive(:record).with('info', /Moving (.*)/)
          allow(FakeLogger).to receive(:record).with('info', /Pruning (.*)/)

          today_str = Time.now.strftime '%Y-%m-%d'

          expect(FakeLogger).to receive(:record)
                                    .with('info', /Backing up to: BACKUP_DIR\/current\.tar\.#{today_str}\.gz/)
          # we created 2 DB backup makers
          expect(FakeLogger).to receive(:record).twice
                                    .with('info', /Backing up to: BACKUP_DIR\/db_backup\.sql\.#{today_str}\.gz/)
          expect(FakeLogger).to receive(:record)
                                    .with('info', /Backing up to: BACKUP_DIR\/backup-FilesBackupMaker\.tar\.#{today_str}\.gz/)

          described_class.condition_response(backup_condition, FakeLogger)
        end

        it 'sends the backup method to each backup maker, which returns the name of the backup file created' do
          expect(@code_backup_maker).to receive(:backup)
          expect(@db_backup_maker1).to receive(:backup)
          expect(@db_backup_maker2).to receive(:backup)
          expect(@file_backup_maker).to receive(:backup)

          described_class.condition_response(backup_condition, FakeLogger)

        end
      end

      it "logs a message that it is 'Moving backup files to AWS S3'" do
        allow(FakeLogger).to receive(:record).with('info', /Backing up to: (.*)/)
        allow(FakeLogger).to receive(:record).with('info', /Pruning (.*)/)

        expect(FakeLogger).to receive(:record).with('info', /Moving (.*)/)
        described_class.condition_response(backup_condition, FakeLogger)
      end

      it 'calls S3 credentials once' do
        expect(described_class).to receive(:get_s3_objects)
                                       .with(today).exactly(1).times

        described_class.condition_response(condition, FakeLogger)
      end

      it 'calls upload to S3 once for each Backup maker ' do
        # if no files are in the config, there are only 2 backup makers
        expect(described_class).to receive(:upload_file_to_s3).exactly(expected_num_makers).times

        described_class.condition_response(condition, FakeLogger)
      end


      describe 'finally it prunes older backups on local storage' do

        it "logs a message that it is 'Pruning older backups on local storage'" do
          allow(FakeLogger).to receive(:record).with('info', /Backing up to: (.*)/)
          allow(FakeLogger).to receive(:record).with('info', /Moving (.*)/)

          expect(FakeLogger).to receive(:record).with('info', /Pruning (.*)/)
          described_class.condition_response(backup_condition, FakeLogger)
        end


        describe 'for each backup_maker it:' do

          it 'gets the file pattern to use to prune older backup files, based on the base_file from the backup_maker' do
            expect(described_class).to receive(:get_backup_files_pattern)
                                           .with('BACKUP_DIR', 'current.tar')
            expect(described_class).to receive(:get_backup_files_pattern)
                                           .with('BACKUP_DIR', 'db_backup.sql')
            expect(described_class).to receive(:get_backup_files_pattern)
                                           .with('BACKUP_DIR', 'db_backup.sql')
            expect(described_class).to receive(:get_backup_files_pattern)
                                           .with('BACKUP_DIR', 'backup-FilesBackupMaker.tar')

            described_class.condition_response(backup_condition, FakeLogger)
          end

          it 'deletes excess backup files that were created by this backup_maker, keeping the number given in the configuration' do

            expect(described_class).to receive(:delete_excess_backup_files)
                                           .with('BACKUP_DIR/current.tar.*', 3)
            expect(described_class).to receive(:delete_excess_backup_files)
                                           .with('BACKUP_DIR/db_backup.sql.*', 2)
            expect(described_class).to receive(:delete_excess_backup_files)
                                           .with('BACKUP_DIR/db_backup.sql.*', 1)
            expect(described_class).to receive(:delete_excess_backup_files)
                                           .with('BACKUP_DIR/backup-FilesBackupMaker.tar.*', 99)

            described_class.condition_response(backup_condition, FakeLogger)
          end

        end

      end

    end


    describe '.create_backup_makers' do

      describe 'number of code backups to keep' do

        it 'CodeBackupMaker number to keep is from config if days_to_keep: {code_backup: N} exists' do
          makers = described_class.create_backup_makers({ days_to_keep: { code_backup: 12 } })
          code_backupmaker = makers.select { |maker_entry| maker_entry[:backup_maker].is_a? CodeBackupMaker }.first
          expect(code_backupmaker[:keep_num]).to eq 12
        end

        it 'CodeBackupMaker number to keep is 4 (default) if not in config' do
          makers = described_class.create_backup_makers({})
          code_backupmaker = makers.select { |maker_entry| maker_entry[:backup_maker].is_a? CodeBackupMaker }.first
          expect(code_backupmaker[:keep_num]).to eq 4
        end
      end

      describe 'number of database backups to keep' do

        it 'DBBackupMaker number to keep is from config if days_to_keep: {db_backup: N} exists' do
          makers = described_class.create_backup_makers({ days_to_keep: { db_backup: 12 } })
          db_backupmaker = makers.select { |maker_entry| maker_entry[:backup_maker].is_a? DBBackupMaker }.first
          expect(db_backupmaker[:keep_num]).to eq 12
        end

        it 'DBBackupMaker number to keep is 15 (default) if not in config' do
          makers = described_class.create_backup_makers({})
          db_backupmaker = makers.select { |maker_entry| maker_entry[:backup_maker].is_a? DBBackupMaker }.first
          expect(db_backupmaker[:keep_num]).to eq 15
        end
      end


      describe 'number of file backups to keep' do
        it 'FilesBackupMaker number to keep is from config if days_to_keep: {files_backup: N} exists' do
          makers = described_class.create_backup_makers({ files: ['thisfile'], days_to_keep: { files_backup: 12 } })
          code_backupmaker = makers.select { |maker_entry| maker_entry[:backup_maker].class.name == 'FilesBackupMaker' }.first
          expect(code_backupmaker[:keep_num]).to eq 12
        end

        it 'FilesBackupMaker number to keep is 31 (default) if not in config' do
          makers = described_class.create_backup_makers({ files: ['thisfile'] })
          code_backupmaker = makers.select { |maker_entry| maker_entry[:backup_maker].class.name == 'FilesBackupMaker' }.first
          expect(code_backupmaker[:keep_num]).to eq 31
        end
      end


      describe 'adds a CodeBackupMaker and a DBBackupMaker' do

        it 'creates a CodeBackupMaker with the number to keep, backup dir,default target filename and source' do
          allow(described_class).to receive(:create_files_backup_maker).and_return(nil)

          makers = described_class.create_backup_makers({ files: ['thisfile'],
                                                          days_to_keep: { files_backup: 12 },
                                                          backup_directory: 'backup/destination/dir' })

          code_backup_makers = makers.select { |maker_entry| maker_entry[:backup_maker].is_a? CodeBackupMaker }
          expect(code_backup_makers.size).to eq 1
        end


        it 'creates a DBBackupMaker with the number to keep, backup dir, default target filename and source' do
          allow(described_class).to receive(:create_files_backup_maker).and_return(nil)

          makers = described_class.create_backup_makers({ files: ['thisfile'],
                                                          days_to_keep: { files_backup: 12 },
                                                          backup_directory: 'backup/destination/dir' })

          db_backup_makers = makers.select { |maker_entry| maker_entry[:backup_maker].is_a? DBBackupMaker }
          expect(db_backup_makers.size).to eq 1
        end
      end


      describe 'only adds a FileBackupMaker if needed' do

        it 'no FileBackupMaker created after reading the config' do
          allow(described_class).to receive(:create_files_backup_maker).and_return(nil)

          makers = described_class.create_backup_makers({ files: ['thisfile'], days_to_keep: { files_backup: 12 } })
          files_backupmaker = makers.select { |maker_entry| maker_entry[:backup_maker].class.name == 'FilesBackupMaker' }

          expect(files_backupmaker).to be_empty
        end

        it 'a FileBackupMaker is created from config info' do

          allow(described_class).to receive(:create_files_backup_maker).and_return(FilesBackupMaker.new)

          makers = described_class.create_backup_makers({ files: ['thisfile'],
                                                          days_to_keep: { files_backup: 12 },
                                                          backup_directory: 'backup/destination/dir' })

          files_backupmaker = makers.select { |maker_entry| maker_entry[:backup_maker].class.name == 'FilesBackupMaker' }
          expect(files_backupmaker.size).to eq 1
        end

      end

    end


    describe '.create_files_backup_maker' do

      it 'nil if there is no files: entry in config' do
        expect(described_class.create_files_backup_maker({})).to be_nil
      end

      it 'raises ShfConditionError::BackupConfigFilesBadFormatError if not an array' do
        expect { described_class.create_files_backup_maker({ files: 'blorf' }) }.to raise_exception(ShfConditionError::BackupConfigFilesBadFormatError)
      end

      it 'nil if the list is empty: []' do
        expect(described_class.create_files_backup_maker({ files: [] })).to be_nil
      end

      it 'creates a FileBackupMaker with the list as the source files for the backup, and destination dir set' do
        created_maker = described_class.create_files_backup_maker({ files: ['~/NOTES_RUNNING_LOG.txt', '/var/log/nginx'],
                                                                    backup_directory: 'backup/destination/dir' })

        expect(created_maker.backup_sources).to match_array(['~/NOTES_RUNNING_LOG.txt', '/var/log/nginx'])
      end

    end


    describe 'get_backup_files_pattern' do

      it 'appends ".*" to the end of the File.join(backup directory, backup file)' do
        expect(described_class.get_backup_files_pattern('dir', 'filename.zzk')).to eq('dir/filename.zzk.*')
      end

      it 'uses File.join so redundant/repeated slashes are not a problem' do
        expect(described_class.get_backup_files_pattern('dir/with/ending/slash/', 'filename.zzk')).to eq('dir/with/ending/slash/filename.zzk.*')
      end
    end


    describe 'log_and_notify' do

      before(:each) do
        @more_info = 'this is additional info'
        @some_error = NameError.new('blorf')
      end


      describe 'writes the error and additional info to the log' do

        before(:each) do
          allow(SHFNotifySlack).to receive(:failure_notification)
                                      .with(anything, anything)
        end

        it 'the error message followed the additional info is sent to the log' do
          expect(FakeLogger).to receive(:error).with("#{@some_error} #{@more_info}")
          described_class.log_and_notify(@some_error, FakeLogger, @more_info)
        end

        describe 'if it cannot write to the log' do

          before(:each ) do
            @logging_error = IOError
            allow(FakeLogger).to receive(:error)
                                         .and_raise(@logging_error)
          end


          it 'logging error not raised and will also send a Slack notification about the logging error' do
            expect(SHFNotifySlack).to receive(:failure_notification)
                                         .with(anything, text: 'original error')

            expect(SHFNotifySlack).to receive(:failure_notification)
                                        .with(anything, text: "Error: Could not write to the log in #{described_class.name}.log_and_notify: #{@logging_error}")

            orig_on_false_positives_setting = RSpec::Expectations.configuration.on_potential_false_positives
            RSpec::Expectations.configuration.on_potential_false_positives = :nothing
            expect{described_class.log_and_notify('original error', FakeLogger)}.not_to raise_error(@logging_error)
            RSpec::Expectations.configuration.on_potential_false_positives = orig_on_false_positives_setting
          end
        end

      end


      describe 'sends a Slack failure notification' do

        before(:each) do
          allow(FakeLogger).to receive(:error)
        end

        it 'text is the error followed by the additional info' do
          expect(SHFNotifySlack).to receive(:failure_notification)
                                        .with(described_class.name, text: "#{@some_error} #{@more_info}")

          described_class.log_and_notify(@some_error, FakeLogger, @more_info)
        end

        describe 'if it cannot send a notification' do

          before(:each ) do
            @slack_error = Slack::Notifier::APIError.new
            allow(SHFNotifySlack).to receive(:failure_notification)
                                         .and_raise(@slack_error)
          end

          it 'will also write the Slack notification error to the log' do
            expect(FakeLogger).to receive(:error)
                                    .with('original error')
            expect(FakeLogger).to receive(:error)
                                    .with("Slack error during #{described_class.name}.log_and_notify: #{@slack_error.inspect}")

            expect{described_class.log_and_notify('original error', FakeLogger)}.to raise_error(@slack_error)
          end

          it 'will raise the Slack error so the caller can handle it as needed' do
            expect{described_class.log_and_notify('original error', FakeLogger)}.to raise_error(@slack_error)
          end
        end
      end
    end


    describe 'iterate_and_log_notify_errors(list, slack_error_details, log)' do

      before(:each) do
        allow(SHFNotifySlack).to receive(:failure_notification)
                                     .with(anything, anything)

        @strings = %w(a b c) # this is the list of items we'll iterate through
        @result_str = ''
      end


      it 'iterates through each item in the list with the yield' do

        described_class.iterate_and_log_notify_errors(@strings, 'error during iteration test', FakeLogger) do | s |
          @result_str << s
        end

        expect(@result_str).to eq 'abc'
      end


      it 'Slack error: is logged with the detail message and raised' do

        expect(FakeLogger).to receive(:error)
                                  .with(/Slack Notification failure during Backup\.condition_response during iteration test. Current item: "b"\: #{Slack::Notifier::APIError}/)

        expect{
        described_class.iterate_and_log_notify_errors(@strings, 'during iteration test', FakeLogger) do | s |
          raise Slack::Notifier::APIError if s == 'b'
          @result_str << s
        end}.to raise_error(Slack::Notifier::APIError)

        expect(@result_str).to eq 'a'
      end


      it 'non-Slack error is logged, notification sent, iteration continues' do

        some_error = NameError

        expected_error_str = "#{some_error} error during iteration test. Current item: \"b\""

        expect(SHFNotifySlack).to receive(:failure_notification).with(anything, text: expected_error_str)
        expect(FakeLogger).to receive(:error).with(expected_error_str)

        described_class.iterate_and_log_notify_errors(@strings, 'error during iteration test', FakeLogger) do | s |
          raise some_error if s == 'b'
          @result_str << s
        end

        expect(@result_str).to eq 'ac'
      end

    end
  end

end

