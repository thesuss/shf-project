# Specs for AbstractBackupMaker and subclasses
# TODO break this up into separate files; break up the models/conditions_response/backup file, too

require 'rails_helper'
require_relative File.join(Rails.root, 'app/models/conditions_response/backup')

require 'shared_examples/backup_maker_target_filename_with_default_spec'



RSpec.describe AbstractBackupMaker do

  describe 'Unit tests' do

    it 'default sources = []' do
      expect(subject.backup_sources).to eq []
    end

    it 'base_filename = backup-<class name>-<DateTime.current>.tar' do
      expect(subject.base_filename).to match(/backup-AbstractBackupMaker\.tar/)
    end



    describe 'shell_cmd' do

      it 'raises an error if one was encountered' do
        allow(Open3).to receive(:capture3).and_raise(Errno::ENOENT, 'blorfo')
        expect { subject.shell_cmd('blorfo') }.to raise_error(Errno::ENOENT, 'No such file or directory - blorfo')
      end

      it 'raises BackupCommandNotSuccessfulError and shows the command, status, stdout, and stderr if it was not successful' do
        allow(Open3).to receive(:capture3).and_return(['output string', 'error string', nil])
        expect { subject.shell_cmd('blorfo') }.to raise_error(ShfConditionError::BackupCommandNotSuccessfulError,
                                                              "Backup Command Failed: blorfo. return status:   Error: error string  Output: output string")
      end

    end

    it 'backup raises NoMethodError Subclasses must define' do
      expect { subject.backup }.to raise_error(NoMethodError, 'Subclass must define the backup method')
    end

  end
end


RSpec.describe FilesBackupMaker do

  describe 'Unit tests' do

    let(:backup_using_defaults) { FilesBackupMaker.new }

    it 'base_filename = backup-FilesBackupMaker.tar' do
      expect(subject.base_filename).to eq 'backup-FilesBackupMaker.tar'
    end


    describe '#backup' do


      it 'uses #shell_cmd to create a tar with all entries in sources using tar -chzf}' do

        temp_backup_sourcedir = Dir.mktmpdir('faux-code-dir')
        temp_backup_sourcefn1 = File.open(File.join(temp_backup_sourcedir, 'faux-codefile.rb'), 'w').path
        temp_backup_sourcefn2 = File.open(File.join(temp_backup_sourcedir, 'faux-otherfile.rb'), 'w').path
        temp_subdir = File.join(temp_backup_sourcedir, 'subdir')
        FileUtils.mkdir_p(temp_subdir)
        temp_backup_in_subdir_fn = File.open(File.join(temp_backup_sourcedir, 'subdir', 'faux-codefile2.rb'), 'w').path

        temp_backup_sourcedir2 = Dir.mktmpdir('faux-code-dir2')
        temp_backup_source2fn1 = File.open(File.join(temp_backup_sourcedir2, 'dir2-faux-codefile.rb'), 'w').path

        temp_backup_target = File.join(Dir.mktmpdir('temp-files-dir'), 'files_backup_fn.zzkx')

        files_backup = described_class.new(target_filename: temp_backup_target,
                                           backup_sources: [temp_backup_sourcedir,
                                                            temp_backup_source2fn1])
        files_backup.backup

        expect(File.exist?(temp_backup_target)).to be_truthy

        # could also use the Gem::Package verify_entry method to verify each tar entry
        backup_file_list = %x<tar --list --file=#{temp_backup_target}>
        backup_file_list.gsub!(/\n/, ' ')
        backup_files = backup_file_list.split(' ')

        # tar will remove leading "/" from source file names, so remove the leading "/"
        expected = [temp_backup_sourcefn1.gsub(/^\//, ''),
                    temp_backup_sourcefn2.gsub(/^\//, ''),
                    temp_backup_in_subdir_fn.gsub(/^\//, ''),
                    "#{temp_subdir.gsub(/^\//, '')}/",
                    "#{temp_backup_sourcedir.gsub(/^\//, '')}/",
                    temp_backup_source2fn1.gsub(/^\//, '')]

        expect(backup_files).to match_array(expected)
      end


      it_behaves_like 'it takes a backup target filename, with default =', 'backup-FilesBackupMaker.tar'


      describe 'source files for the backup' do

        it "default sources = [] (none)" do
          expect(subject).to receive(:shell_cmd)
                                 .with(/tar -chzf (.*) #{[].join(' ')}/)
          subject.backup
        end


        it 'can provide the sources' do

          files_backup = described_class.new

          source_dir = Dir.mktmpdir('backup-sources-dir')
          source_files = []
          3.times do |i|
            fn = File.join(source_dir, "source-#{i}.txt")
            File.open(fn, 'w'){|f| f.puts "blorf"}
            source_files << fn
          end

          expect(files_backup).to receive(:shell_cmd)
                                      .with(/tar -chzf (.*) #{source_files.join(' ')}/)
                                      .and_call_original

          backup_created = files_backup.backup(sources: source_files)
          puts "backup_created: #{backup_created}"

          expect(File.exist?(backup_created)).to be_truthy
          File.delete(backup_created)
        end

      end

      it 'will fail unless sources are provided (tar will fail with an empty list)' do
        expect{subject.backup}.to raise_error(ShfConditionError::BackupCommandNotSuccessfulError, /tar/)
      end
    end

  end
end


RSpec.describe CodeBackupMaker do

  describe 'Unit tests' do

    it 'base_filename = current.tar' do
      expect(subject.base_filename).to eq 'current.tar'
    end

    it 'default sources = [/var/www/shf/current/]' do
      expect(subject.backup_sources).to eq ['/var/www/shf/current/']
    end


    describe 'backup' do

      it 'will not fail if no sources specified (since default should have files in the directory)' do

        source_dir = Dir.mktmpdir('backup-source-dir')
        source_files = []
        3.times do |i|
          fn = File.join(source_dir, "source-#{i}.txt")
          File.open(fn, 'w'){|f| f.puts "blorf"}
          source_files << fn
        end

        allow(subject).to receive(:default_sources).and_return(source_files)

        target_backup_fn = 'target.bak'
        expect{subject.backup(target: target_backup_fn)}.not_to raise_error(ShfConditionError::BackupCommandNotSuccessfulError, /tar: no files or directories specified/)
        File.delete(target_backup_fn)
      end
    end
  end
end


RSpec.describe DBBackupMaker do

  describe 'Unit tests' do

    let(:backup_using_defaults) { DBBackupMaker.new }

    it 'base_filename = db_backup.sql' do
      expect(subject.base_filename).to eq 'db_backup.sql'
    end

    it 'default sources = [DB_NAME]' do
      expect(subject.backup_sources).to eq ['shf_project_production']
    end

    describe '#backup' do

      describe 'dumps the dbs in sources and creates 1 backup gzipped file' do

        before(:each) { @temp_dir = Dir.mktmpdir('db-backup-source-dir') }

        it 'using default target' do

          new_db_backup = described_class.new(backup_sources: ['this1', 'that2'])

          expected_backup_fname = 'db_backup.sql'
          expect(new_db_backup).to receive(:shell_cmd).with("touch #{expected_backup_fname}").and_call_original
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d this1 | gzip > #{expected_backup_fname}")
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d that2 | gzip > #{expected_backup_fname}")

          new_db_backup.backup()

          expect(File.exist?(expected_backup_fname)).to be_truthy
          File.delete(expected_backup_fname)
        end

        it 'given a filename to use as the target' do

          temp_backup_target = File.join(@temp_dir, 'db_dumped.sql')

          new_db_backup = described_class.new(target_filename: temp_backup_target,
                                              backup_sources: ['this1', 'that2'])

          expected_backup_fname = temp_backup_target
          expect(new_db_backup).to receive(:shell_cmd).with("touch #{expected_backup_fname}").and_call_original
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d this1 | gzip > #{expected_backup_fname}")
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d that2 | gzip > #{expected_backup_fname}")

          new_db_backup.backup
          expect(File.exist?(expected_backup_fname)).to be_truthy
        end
      end


      it_behaves_like 'it takes a backup target filename, with default =', 'db_backup.sql'

      describe 'source files for the backup' do

        before(:each) { allow(subject).to receive(:shell_cmd).with(/touch (.*)/) }

        it 'default sources = [shf_project_production]' do
          expect(subject).to receive(:shell_cmd)
                                 .with(/pg_dump (.*) shf_project_production/)
          subject.backup
        end


        it 'can provide the sources' do

          source_files = ['some.db', 'some-other.db', 'a-production.db']

          expect(subject).to receive(:shell_cmd).with(/pg_dump (.*) some.db/)
          expect(subject).to receive(:shell_cmd).with(/pg_dump (.*) some-other.db/)
          expect(subject).to receive(:shell_cmd).with(/pg_dump (.*) a-production.db/)

          subject.backup(sources: source_files)
        end

      end

      it 'will not fail if no sources are specified since default is not empty' do
        expect(subject).to receive(:shell_cmd).with(/touch (.*)/)
        expect(subject).to receive(:shell_cmd)
                               .with(/pg_dump (.*) shf_project_production/)
        subject.backup
      end

    end

  end
end
