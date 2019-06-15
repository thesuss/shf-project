# Backup code and DB data in production

CODE_ROOT_DIRECTORY = '/var/www/shf/current/'
DB_NAME = 'shf_project_production'
LOGS_ROOT_DIRECTORY = '/var/log'

# Errors
module ShfConditionError
  class BackupError < StandardError
  end

  class BackupConfigFilesBadFormatError < BackupError
  end

  class BackupCommandNotSuccessfulError < BackupError
  end
end

# @desc Abstract class for all backup classes.
#   backup_sources = the list of files or glob pattern of the files to be backed up
#   backup_target_filebase = the basic filename created by backing up the sources. Info
#    is added to this basic filename (e.g. the date is added,
#    perhaps another extension is appended like '.gz')
#
# Each Backup class must implement :backup(backup_target, sources) to do whatever
# it needs to do to create the backup
#
class AbstractBackupMaker

  attr :backup_target_filebase, :backup_sources

  # Set the backup target and the backup sources
  def initialize(backup_target_filebase: default_backup_filebase, backup_sources: default_sources)
    @backup_target_filebase = backup_target_filebase
    @backup_sources = backup_sources
  end


  # Do the backup. Default target is the backup_target_filebase; default sources = the backup sources)
  def backup(_target = backup_target_filebase, _sources = backup_sources)
    raise NoMethodError, "Subclass must define the #{__method__} method", caller
  end


  def default_backup_filebase
    "backup-#{self.class.name}.tar"
  end


  def default_sources
    []
  end


  # Run the command using Open3 which allows us to capture the output and status
  # Raise an error unless the return status is success
  def shell_cmd(cmd)
    stdout_str, stderr_str, status = Open3.capture3(cmd)
    unless status&.success?
      raise(ShfConditionError::BackupCommandNotSuccessfulError, "Command: #{cmd}. return status: #{status}  Error: #{stderr_str}  Output: #{stdout_str}")
    end
  end

end


# Backup a list of files using tar. Create 1 resulting backup file
class FilesBackupMaker < AbstractBackupMaker

  # use tar to compress all sources into the file named by target
  def backup(target = backup_target_filebase, sources = backup_sources)
    shell_cmd("tar -chzf #{target} #{sources.join(' ')}")
  end

end


# Backup a list of code directories.  Create 1 resulting backup file 'current.tar'
class CodeBackupMaker < FilesBackupMaker

  DEFAULT_SOURCES = [CODE_ROOT_DIRECTORY]
  DEFAULT_BACKUP_FILEBASE = 'current.tar'


  def default_backup_filebase
    DEFAULT_BACKUP_FILEBASE
  end


  def default_sources
    [CODE_ROOT_DIRECTORY]
  end
end


# Backup a list of databases. For each database: first use pg_dump to dump it,
# then add it to a gzip file.
# Create 1 resulting gzip file
#
class DBBackupMaker < AbstractBackupMaker

  DB_BACKUP_FILEBASE = 'db_backup.sql'

  # Backup all Postgres databases in sources, then gzip them into the target
  def backup(target = backup_target_filebase, sources = backup_sources)

    shell_cmd("touch #{target}")

    sources.each do |source|
      shell_cmd("pg_dump -d #{source} | gzip > #{target}")
    end

  end


  def default_backup_filebase
    DB_BACKUP_FILEBASE
  end


  def default_sources
    [DB_NAME]
  end
end


class Backup < ConditionResponder


  DEFAULT_BACKUP_FILES_DIR = '/home/deploy/SHF_BACKUPS/'
  DEFAULT_CODE_BACKUPS_TO_KEEP = 4
  DEFAULT_DB_BACKUPS_TO_KEEP = 15
  DEFAULT_FILE_BACKUPS_TO_KEEP = 31

  TIMESTAMP_FMT = '%Y-%m-%d'

  # -------------


  def self.condition_response(condition, log)

    validate_timing(get_timing(condition), [TIMING_EVERY_DAY], log)

    config = get_config(condition)
    backup_makers = create_backup_makers(config)

    # Backup each backup_maker to local storage

    backup_files = []
    backup_dir = backup_dir(config)

    backup_makers.each do |backup_maker|

      backup_file = backup_target_fn(backup_dir, backup_maker[:backup_maker].backup_target_filebase)
      backup_files << backup_file

      log.record('info', "Backing up to: #{backup_file}")

      # this will use the default source and target set when the backup maker was created
      backup_maker[:backup_maker].backup
    end


    # Copy backup files to S3

    log.record('info', 'Moving backup files to AWS S3')

    s3, bucket, bucket_folder = get_s3_objects(today_timestamp)

    backup_files.each { |file| upload_file_to_s3(s3, bucket, bucket_folder, file) }


    # Prune older backups beyond "keep" (days) limit

    log.record('info', 'Pruning older backups on local storage')

    backup_makers.each do |backup_maker|

      file_pattern = get_backup_files_pattern(backup_dir, backup_maker[:backup_maker].backup_target_filebase)

      delete_excess_backup_files(file_pattern, backup_maker[:keep_num])

    end
  end


  def self.backup_dir(config)
    config.dig(:backup_directory) || DEFAULT_BACKUP_FILES_DIR
  end


  def self.backup_target_fn(backup_dir, backup_base_fn)
    File.join(backup_dir, backup_base_fn + today_timestamp + '.gz')
  end


  def self.today_timestamp
    Time.now.strftime TIMESTAMP_FMT
  end


  def self.get_s3_objects(today_ts = today_timestamp)

    s3 = Aws::S3::Resource.new(
        region: ENV['SHF_AWS_S3_BACKUP_REGION'],
        credentials: Aws::Credentials.new(ENV['SHF_AWS_S3_BACKUP_KEY_ID'],
                                          ENV['SHF_AWS_S3_BACKUP_SECRET_ACCESS_KEY']))

    bucket = ENV['SHF_AWS_S3_BACKUP_BUCKET']

    bucket_folder = "production_backup/#{today_ts}/" # S3 will show objects in folders

    [s3, bucket, bucket_folder]
  end


  def self.upload_file_to_s3(s3, bucket, bucket_folder, file)
    obj = s3.bucket(bucket).object(bucket_folder + File.basename(file))

    obj.upload_file(file)
  end


  def self.get_backup_files_pattern(backup_dir, beginning_of_file_name)
    File.join(backup_dir,beginning_of_file_name) + '.*'
  end


  def self.delete_excess_backup_files(file_pattern, number_of_files_to_keep)

    backup_files = Dir.glob(file_pattern)

    number_of_backup_files = backup_files.length

    if number_of_backup_files > number_of_files_to_keep

      delete_files = backup_files.sort[0, number_of_backup_files - number_of_files_to_keep]

      delete_files.each { |file| File.delete(file) }
    end
  end


  def self.create_backup_makers(config)
    num_code_backups_to_keep = config.dig(:days_to_keep, :code_backup) || DEFAULT_CODE_BACKUPS_TO_KEEP
    num_db_backups_to_keep = config.dig(:days_to_keep, :db_backup) || DEFAULT_DB_BACKUPS_TO_KEEP
    num_file_backups_to_keep = config.dig(:days_to_keep, :files_backup) || DEFAULT_FILE_BACKUPS_TO_KEEP

    # :keep_num key defines how many daily backups to retain on _local_ storage (e.g. on the production machine)
    # AWS (S3) backup files are retained based on settings in AWS.
    backup_makers = [
        { backup_maker: CodeBackupMaker.new, keep_num: num_code_backups_to_keep },
        { backup_maker: DBBackupMaker.new, keep_num: num_db_backups_to_keep }
    ]

    files_backup_maker = create_files_backup_maker(config)
    backup_makers << { backup_maker: files_backup_maker, keep_num: num_file_backups_to_keep } if files_backup_maker

    backup_makers
  end


  # only create a FilesBackupMaker if there is a list of files to be backed up
  def self.create_files_backup_maker(config)
    files_backup_maker = nil
    if (backup_files = config.fetch(:files, false))

      unless backup_files.is_a?(Array)
        raise ShfConditionError::BackupConfigFilesBadFormatError.new('Backup Condition configuration for :files is bad.  Must be an Array.')
      end

      files_backup_maker = FilesBackupMaker.new(backup_sources: backup_files) unless backup_files.empty?
    end

    files_backup_maker
  end
end
