module ShfBackupMakers

  #--------------------------
  #
  # @class ShfBackupMakers::DBBackupMaker
  #
  # @desc Responsibility: Create a backup of Postgres databases using pg_dump.
  #         For each database: first use pg_dump to dump it,
  #           then add it to a gzip file.
  #         Create 1 resulting gzip file
  #         The base filename is 'db_backup.sql'
  #         default_sources is the production database
  #
  #  @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  #  @date   2019-06-15
  #
  #--------------------------
  class DBBackupMaker < AbstractBackupMaker

    DB_NAME = 'shf_project_production'
    DB_BACKUP_FILEBASE = 'db_backup.sql'

    # Backup all Postgres databases in sources, then gzip them into the target
    # @return [String] - filename of the backup target created
    def backup(target: target_filename, sources: backup_sources)

      shell_cmd("touch #{target}") # must ensure the file exists

      sources.each do |source|
        shell_cmd("pg_dump -d #{source} | gzip > #{target}")
      end
      target
    end


    def base_filename
      DB_BACKUP_FILEBASE
    end


    def default_sources
      [DB_NAME]
    end
  end

end
