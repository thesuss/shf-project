# Specs for AbstractBackupMaker and subclasses

require 'rails_helper'

require_relative File.join(Rails.root, 'app/models/conditions_response/backup')


RSpec.describe AbstractBackupMaker do

  describe 'Unit tests' do

    it 'default sources = []' do
      expect(subject.backup_sources).to eq []
    end

    it 'default backup target base filename = backup-<class name>-<DateTime.current>.tar' do
      expect(subject.backup_target_filebase).to match(/backup-AbstractBackupMaker\.tar/)
    end

    describe 'shell_cmd' do

      it 'raises an error if one was encountered' do
        allow(Open3).to receive(:capture3).and_raise(Errno::ENOENT, 'blorfo')
        expect{ subject.shell_cmd('blorfo')}.to raise_error(Errno::ENOENT, 'No such file or directory - blorfo')
      end

      it 'raises BackupCommandNotSuccessfulError and shows the command, status, stdout, and stderr if it was not successful' do
        allow(Open3).to receive(:capture3).and_return(['output string', 'error string', nil])
        expect{ subject.shell_cmd('blorfo')}.to raise_error(ShfConditionError::BackupCommandNotSuccessfulError,
                                                            "Command: blorfo. return status:   Error: error string  Output: output string")
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

    it 'default backup target base filename = backup-FilesBackupMaker.tar' do
      expect(subject.backup_target_filebase).to eq 'backup-FilesBackupMaker.tar'
    end


    describe '#backup' do

      it 'uses #shell_cmd to create a tar with all entries in sources using tar -chzf}' do

        temp_backup_target = Tempfile.new('code-backup.').path
        temp_backup_sourcefn1 = Tempfile.new('faux-codefile.rb').path
        temp_backup_sourcefn2 = Tempfile.new('faux-otherfile.rb').path

        temp_backup_sourcedir = Dir.mktmpdir('faux-code-dir')
        temp_backup_in_dir_fn = File.open(File.join(temp_backup_sourcedir, 'faux-codefile2.rb'), 'w').path

        files_backup = described_class.new(backup_target_filebase: temp_backup_target,
                                           backup_sources: [temp_backup_sourcefn1,
                                                            temp_backup_sourcefn2,
                                                            temp_backup_sourcedir])
        files_backup.backup

        # could also use the Gem::Package verify_entry method to verify each tar entry
        backup_file_list = %x<tar --list --file=#{temp_backup_target}>
        backup_file_list.gsub!(/\n/, ' ')

        # tar will remove leading "/" from source file names, so remove the leading "/"
        expected = "#{temp_backup_sourcefn1.gsub(/^\//, '')} " +
            "#{temp_backup_sourcefn2.gsub(/^\//, '')} " +
            "#{temp_backup_sourcedir.gsub(/^\//, '')}/ " +
            "#{temp_backup_in_dir_fn.gsub(/^\//, '')}"

        expect(backup_file_list.strip).to eq expected

        FileUtils.remove_entry temp_backup_sourcedir
      end

    end

  end
end


RSpec.describe CodeBackupMaker do

  describe 'Unit tests' do

    it 'default backup target base filename = current.tar' do
      expect(subject.backup_target_filebase).to eq 'current.tar'
    end

    it 'default sources = [CODE_ROOT_DIRECTORY]' do
      expect(subject.backup_sources).to eq ['/var/www/shf/current/']
    end

  end
end


RSpec.describe DBBackupMaker do

  describe 'Unit tests' do

    let(:backup_using_defaults) { DBBackupMaker.new }

    it 'default backup target base filename = db_backup.sql' do
      expect(subject.backup_target_filebase).to eq 'db_backup.sql'
    end

    it 'default sources = [DB_NAME]' do
      expect(subject.backup_sources).to eq ['shf_project_production']
    end


    describe '#backup' do

      describe 'dumps the dbs in sources and creates 1 backup gzipped file' do

        it 'using default target' do

          new_db_backup = described_class.new(backup_sources: ['this1', 'that2'])

          expect(new_db_backup).to receive(:shell_cmd).with("touch db_backup.sql")
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d this1 | gzip > db_backup.sql")
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d that2 | gzip > db_backup.sql")

          new_db_backup.backup
        end

        it 'given a filename to use as the target' do

          temp_backup_target = Tempfile.new('code-backup.').path

          new_db_backup = described_class.new(backup_target_filebase: temp_backup_target, backup_sources: ['this1', 'that2'])

          expect(new_db_backup).to receive(:shell_cmd).with("touch #{temp_backup_target}")
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d this1 | gzip > #{temp_backup_target}")
          expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d that2 | gzip > #{temp_backup_target}")

          new_db_backup.backup
        end
      end
    end


  end
end
