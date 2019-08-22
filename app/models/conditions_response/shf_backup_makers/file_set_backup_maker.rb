require_relative File.join(__dir__, '..', 'shf_condition_error_backup_error.rb')

#--------------------------
# Errors
module ShfConditionError

  class BackupFileSetMissingNameError < BackupError
  end

  class BackupFileSetNameCantBeBlankError < BackupError
  end

end
#--------------------------


module ShfBackupMakers

  #--------------------------
  #
  # @class ShfBackupMakers::FileSetBackupMaker
  #
  # @desc Responsibility: Create a backup using tar to compress the sources together.
  #     The backup maker has a name, the target backup filename, a list of files
  #     to backup ('sources'), and a list of patterns for excluding sources.
  #     - name: (required) This is so that both the configuration information
  #       and reporting (e.g. notification) is descriptive.
  #     - exclusions: specify items to be excluded from the tar. This is a list
  #       of strings that the tar command accepts
  #     - days_to_keep: the number of days to keep the local backups
  #
  #
  #  @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  #  @date   2019-06-15
  #
  #--------------------------
  class FileSetBackupMaker < AbstractBackupMaker

    DEFAULT_DAYS_TO_KEEP = 3

    attr_accessor :name, :excludes, :days_to_keep, :base_filename


    # name: is required
    def initialize(args)

      name = args.fetch(:name, false)
      raise ShfConditionError::BackupFileSetMissingNameError unless name
      raise ShfConditionError::BackupFileSetNameCantBeBlankError if name.blank?

      @name = name
      @excludes = args.fetch(:excludes, [])
      @days_to_keep = args.fetch(:days_to_keep, DEFAULT_DAYS_TO_KEEP)
      @base_filename = args.fetch(:base_filename, base_filename_from(name))

      fsb_attribs = [:name, :excludes, :days_to_keep, :base_filename]
      super_args = args.reject { |key, _value| fsb_attribs.include? key }

      super(super_args)
    end


    # Use tar to compress all sources into the file named by target_filename,
    #  passing each item in excludes as an '--exclude=' option to tar.
    #  Creates a gzip format file (the 'z' option used with tar).
    #
    # @url http://man7.org/linux/man-pages/man1/tar.1.html
    #
    # @param [String] target - filename of the backup to be created. Should include the full path
    # @param [Array[String]] sources - list of the filenames to include.
    #
    # @return [String] - the name of the backup target created
    #
    def backup(target: target_filename, sources: backup_sources)
      shell_cmd("tar #{tar_options} #{file_target_opt(target)} #{exclude_opts} #{sources.join(' ')}")
      target
    end


    # ===================================================


    private


    def base_filename_from(str)
      # replace spaces with an underscore and remove anything other than
      # dashes, underscores, 0-9, a-z, A-Z
      "#{str.gsub(/\s/, '_').gsub(/[^\w\-]/, '')}.tar"
    end


    def tar_options
      "--create --gzip --dereference"
    end


    # --file option for the tar command
    def file_target_opt(target_fn)
      "--file=#{target_fn}"
    end


    # --exclude option for the tar command
    def exclude_opts
      excludes.map { |exclude_pattern|
        "--exclude='#{exclude_pattern}'"
      }.join(' ')
    end

  end

end
