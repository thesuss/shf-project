module ShfBackupMakers

  #--------------------------
  #
  # @class ShfBackupMakers::AbstractBackupMaker
  #
  # @desc Responsibility: Create a backup given a list of sources to be backed up.
  #       Abstract class for all Backup Maker classes: classes that know how
  #       to actually make a backup.
  #       Each Backup class must implement :backup(backup_target, sources)
  #       to do whatever it needs to do to create the backup
  #
  # base_filename - the default target filename.
  #                 This does _not_ have a directory, it is only a filename
  #                 and extension.
  #                 This can be used to construct a full filename for the
  #                 target_filename for the backup.
  #
  # target_filename - the filename used for the backup file that is created
  #                   The default value for this is the base_filename.
  #
  # backup_sources - a list that is used as the source for the backups.
  #                  Subclasses use this list to create their backups.
  #                  This is what is backed up.
  #
  #  @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  #  @date   2019-06-15
  #
  #--------------------------
  class AbstractBackupMaker


    attr :target_filename, :backup_sources


    # Set the backup target and the backup sources
    def initialize(target_filename: base_filename,
                   backup_sources: default_sources)
      @target_filename = target_filename
      @backup_sources = backup_sources
    end


    # Do the backup. Default target is the target_filename; default sources = the backup sources)
    def backup(target: target_filename, sources: backup_sources)
      raise NoMethodError, "Subclass must define the #{__method__} method", caller
    end


    # Use the class name, but remove any leading module name so
    # we don't get 'Module::' in the result
    def base_filename
      "backup-#{self.class.name.demodulize}.tar"
    end


    def default_sources
      []
    end


    # Run the command using Open3 which allows us to capture the output and status
    # Raise an error unless the return status is success
    def shell_cmd(cmd)
      stdout_str, stderr_str, status = Open3.capture3(cmd)
      unless status&.success?
        raise(ShfConditionError::BackupCommandNotSuccessfulError, "Backup Command Failed: #{cmd}. return status: #{status}  Error: #{stderr_str}  Output: #{stdout_str}")
      end
    end

  end

end
