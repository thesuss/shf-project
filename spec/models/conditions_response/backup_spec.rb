require 'rails_helper'

require 'shared_examples/shared_condition_specs'



RSpec.describe Backup, type: :model do

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

    it 'joins the given directory with the given filename, appends a timestamp and .gz to the base filename' do
      timestamp = Time.now.strftime Backup::TIMESTAMP_FMT
      expect(described_class.backup_target_fn('blorf-dir', 'blorf')).to eq(File.join('blorf-dir', "blorf#{timestamp}.gz"))
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
      @code_backup_maker = CodeBackupMaker.new(backup_target_filebase: 'code_backup_maker_target_file.tar')
      @db_backup_maker1 = DBBackupMaker.new(backup_target_filebase: 'db_backup_maker_target_file.sql')
      @db_backup_maker2 = DBBackupMaker.new(backup_target_filebase: 'another_db_backup_maker_target_file.flurb')
      @file_backup_maker = FilesBackupMaker.new(backup_target_filebase: 'files_maker_target_file.tar',
                                                backup_sources: ['file1.txt', 'file2.zip'])
      @created_backup_makers = [
          { backup_maker: @code_backup_maker, keep_num: 3 },
          { backup_maker: @db_backup_maker1, keep_num: 2 },
          { backup_maker: @db_backup_maker2, keep_num: 1 },
          { backup_maker: @file_backup_maker, keep_num: 99 }
      ]

      # Individual tests below might change or set an expectation
      allow_any_instance_of(AbstractBackupMaker).to receive(:shell_cmd)
      allow(described_class).to receive(:validate_timing)

      allow(described_class).to receive(:backup_dir)
                                    .and_return('BACKUP_DIR')
      allow(described_class).to receive(:create_backup_makers)
                                    .and_return(@created_backup_makers)
      allow(described_class).to receive(:backup_target_fn)
                                    .and_return(%w(BACKUP_DIR/code_backup_maker_target_file.zzz BACKUP_DIR/db_backup_maker_target_file.sql BACKUP_DIR/another_db_backup_maker_target_file.flurb BACKUP_DIR/files_maker_target_file.tar))

      allow(described_class).to receive(:get_s3_objects)
      allow(described_class).to receive(:upload_file_to_s3)
      allow(described_class).to receive(:get_backup_files_pattern)
      allow(described_class).to receive(:delete_excess_backup_files)
    end

    let(:expected_num_makers) { @created_backup_makers.size }


    it_behaves_like 'it validates timings in .condition_response', [:every_day] do
      let(:tested_condition) { condition }
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

      it 'gets the maker backup file name and adds it to the list of backup files created' do

        expect(described_class).to receive(:backup_target_fn)
                                       .with('BACKUP_DIR', 'code_backup_maker_target_file.tar')
        expect(described_class).to receive(:backup_target_fn)
                                       .with('BACKUP_DIR', 'db_backup_maker_target_file.sql')
        expect(described_class).to receive(:backup_target_fn)
                                       .with('BACKUP_DIR', 'another_db_backup_maker_target_file.flurb')
        expect(described_class).to receive(:backup_target_fn)
                                       .with('BACKUP_DIR', 'files_maker_target_file.tar')

        described_class.condition_response(backup_condition, FakeLogger)
      end

      it "logs a message that it is 'Backing up to: <the backup file>'" do
        allow(FakeLogger).to receive(:record).with('info', /Moving (.*)/)
        allow(FakeLogger).to receive(:record).with('info', /Pruning (.*)/)

        expect(FakeLogger).to receive(:record).with('info', /Backing up to: (.*)/)
                                  .exactly(expected_num_makers).times

        described_class.condition_response(backup_condition, FakeLogger)
      end

      it 'sends the backup method to each backup maker, which creates the backup file for the maker' do
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

        it 'gets the file pattern to use to prune older backup files for the backup_maker' do
          expect(described_class).to receive(:get_backup_files_pattern)
                                         .with('BACKUP_DIR', 'code_backup_maker_target_file.tar')
          expect(described_class).to receive(:get_backup_files_pattern)
                                         .with('BACKUP_DIR', 'db_backup_maker_target_file.sql')
          expect(described_class).to receive(:get_backup_files_pattern)
                                         .with('BACKUP_DIR', 'another_db_backup_maker_target_file.flurb')
          expect(described_class).to receive(:get_backup_files_pattern)
                                         .with('BACKUP_DIR', 'files_maker_target_file.tar')

          described_class.condition_response(backup_condition, FakeLogger)
        end

        it 'deletes excess backup files that were created by this backup_maker, keeping the number given in the configuration' do
          allow(described_class).to receive(:get_backup_files_pattern)
                                        .with('BACKUP_DIR', 'code_backup_maker_target_file.tar')
                                        .and_return('code_backup_maker_target_file.tar.*')
          allow(described_class).to receive(:get_backup_files_pattern)
                                        .with('BACKUP_DIR', 'db_backup_maker_target_file.sql')
                                        .and_return('db_backup_maker_target_file.sql.*')
          allow(described_class).to receive(:get_backup_files_pattern)
                                        .with('BACKUP_DIR', 'another_db_backup_maker_target_file.flurb')
                                        .and_return('another_db_backup_maker_target_file.flurb.*')
          allow(described_class).to receive(:get_backup_files_pattern)
                                        .with('BACKUP_DIR', 'files_maker_target_file.tar')
                                        .and_return('files_maker_target_file.tar.*')

          expect(described_class).to receive(:delete_excess_backup_files)
                                         .with('code_backup_maker_target_file.tar.*', 3)
          expect(described_class).to receive(:delete_excess_backup_files)
                                         .with('db_backup_maker_target_file.sql.*', 2)
          expect(described_class).to receive(:delete_excess_backup_files)
                                         .with('another_db_backup_maker_target_file.flurb.*', 1)
          expect(described_class).to receive(:delete_excess_backup_files)
                                         .with('files_maker_target_file.tar.*', 99)

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

      it 'creates a CodeBackupMaker with the number to keep and default target filename and source' do
        allow(described_class).to receive(:create_files_backup_maker).and_return(nil)

        makers = described_class.create_backup_makers({ files: ['thisfile'], days_to_keep: { files_backup: 12 } })
        expect( makers.select { |maker_entry| maker_entry[:backup_maker].is_a? CodeBackupMaker }.size).to eq 1
      end


      it 'creates a DBBackupMaker with the number to keep and default target filename and source' do
        allow(described_class).to receive(:create_files_backup_maker).and_return(nil)

        makers = described_class.create_backup_makers({ files: ['thisfile'], days_to_keep: { files_backup: 12 } })
        expect(makers.select { |maker_entry| maker_entry[:backup_maker].is_a? DBBackupMaker }.size).to eq 1
      end
    end


    describe 'only adds a FileBackupMaker if needed' do

      it 'no FileBackupMaker created after reading the config' do
        allow(described_class).to receive(:create_files_backup_maker).and_return(nil)

        makers = described_class.create_backup_makers({ files: ['thisfile'], days_to_keep: { files_backup: 12 } })
        files_backupmaker = makers.select { |maker_entry| maker_entry[:backup_maker].class.name == 'FilesBackupMaker' }

        expect(files_backupmaker).to be_empty
      end

      it 'a FileBackupMaker is created after reading the config' do

        allow(described_class).to receive(:create_files_backup_maker).and_return(FilesBackupMaker.new)

        makers = described_class.create_backup_makers({ files: ['thisfile'], days_to_keep: { files_backup: 12 } })
        files_backupmaker = makers.select { |maker_entry| maker_entry[:backup_maker].class.name == 'FilesBackupMaker' }

        expect(files_backupmaker).not_to be_empty
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

    it 'creates a FileBackupMaker with the list as the source files for the backup' do
      created_maker = described_class.create_files_backup_maker({ files: ['~/NOTES_RUNNING_LOG.txt', '/var/log/nginx'] })
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
end
