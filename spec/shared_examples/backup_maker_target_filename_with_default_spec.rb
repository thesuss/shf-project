# Shared example for Backup


RSpec.shared_examples 'it takes a backup target filename, with default =' do |default_filename|

  before(:each) do
    @temp_backup_sourcedir = Dir.mktmpdir('faux-code-dir')
    @temp_backup_sourcefn1 = File.open(File.join(@temp_backup_sourcedir, 'some-sourcefile.txt'), 'w').path
  end

  describe 'target filename (the name of the backup file created)' do

    it "default target backup file is '#{default_filename}'" do
      files_backup = described_class.new(backup_sources: [@temp_backup_sourcefn1])
      backup_created_fn = files_backup.backup

      expect(backup_created_fn).to eq default_filename
      expect(File.exist?(default_filename)).to be_truthy
      File.delete(default_filename)
    end

    it 'can provide the name of the file' do
      files_backup = described_class.new(backup_sources: [@temp_backup_sourcefn1])

      target_dir = Dir.mktmpdir('backup-target-dir')
      given_backup_target_fn = File.join(target_dir, 'some_filename.tar.zzzx')

      files_backup.backup(target: given_backup_target_fn)

      expect(File.exist?(given_backup_target_fn)).to be_truthy
      File.delete(given_backup_target_fn)
    end
  end

end
