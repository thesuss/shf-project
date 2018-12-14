require 'active_support/logger'
require 'slack-notifier'

LOG_FILE         = 'log/backup'
BACKUP_FILES_DIR = '/home/deploy/SHF_BACKUPS/'

CODE_BACKUPS_TO_KEEP = 4
DB_BACKUPS_TO_KEEP   = 15

SLACK_COLOR_LTBLUE  = '#439FE0'
SLACK_SUCCESS_COLOR = "good"
SLACK_FAIL_COLOR    = "danger"
SLACK_SUCCESS_EMOJI = ':white_check_mark:'
SLACK_FAIL_EMOJI    = ':x:'


# "keep" key defines how many backups (code or DB) to retain on _local_ storage.
# AWS (S3) backup files are retained based on settings in AWS.
BACKUP_TARGETS = [
    { location: '/var/www/shf/current/', filebase: 'current.tar.',
      type:     'file', keep: CODE_BACKUPS_TO_KEEP },
    { location: 'shf_project_production', filebase: 'db_backup.sql.',
      type:     'db', keep: DB_BACKUPS_TO_KEEP }
]


def slack_success_notification(task_name, notification_text, emoji: SLACK_SUCCESS_EMOJI)

  slack_notification(task_name, notification_text, emoji: emoji,
                     color:                               SLACK_SUCCESS_COLOR)

end


def slack_fail_notification(task_name, notification_text, emoji: SLACK_FAIL_EMOJI)

  slack_notification(task_name, notification_text, emoji: emoji,
                     color:                               SLACK_FAIL_COLOR)

end


# Sends a notification to Slack. Adds timestamps to the text and uses the emoji.
#
# @param source_name [String] - shows in the footer so we know the source of the message
# @param notification_text [String] - main text for the notification
# @param emoji [String] (optional) - emoji name to use; must be in the
#                   Slack format  ":emojiname:"
#                   see https://www.webpagefx.com/tools/emoji-cheat-sheet/
def slack_notification(source_name, notification_text,
                       emoji: SLACK_SUCCESS_EMOJI,
                       color: SLACK_COLOR_LTBLUE)

  slack_notifier = Slack::Notifier.new ENV['SHF_SLACK_WEBHOOKURL'] do
    defaults channel:  ENV['SHF_SLACK_CHANNEL'],
             username: ENV['SHF_SLACK_USERNAME']
  end

  success_timestamp = DateTime.now.utc

  text = "#{notification_text} #{success_timestamp}"

  details = {
      'fallback': text,
      'color':    color,
      'title':    text,
      'footer':   "SHF: #{source_name}",
      'ts':       success_timestamp.to_i
  }
  slack_notifier.post attachments: [details], icon_emoji: emoji

end


desc 'backup code and DB'
task :backup => [:environment] do |task|

  ActivityLogger.open(LOG_FILE, 'SHF_TASK', 'Backup') do |log|

    begin

      today = Time.now.strftime '%Y-%m-%d'

      # Backup to local storage

      backup_files = []

      BACKUP_TARGETS.each do |backup_target|

        backup_file = BACKUP_FILES_DIR + backup_target[:filebase] + today + '.gz'
        backup_files << backup_file

        log.record('info', "Backing up to: #{backup_file}")

        case backup_target[:type]
          when 'file'
            %x<tar -chzf #{backup_file} #{backup_target[:location]}>

          when 'db'
            %x(pg_dump -d #{backup_target[:location]} | gzip > #{backup_file})

        end

      end

      # Copy backup files to S3

      log.record('info', 'Moving backup files to AWS S3')

      s3 = Aws::S3::Resource.new(
          region:      ENV['SHF_AWS_S3_BACKUP_REGION'],
          credentials: Aws::Credentials.new(ENV['SHF_AWS_S3_BACKUP_KEY_ID'],
                                            ENV['SHF_AWS_S3_BACKUP_SECRET_ACCESS_KEY']))

      bucket = ENV['SHF_AWS_S3_BACKUP_BUCKET']

      bucket_folder = "production_backup/#{today}/" # S3 will show objects in folders

      backup_files.each do |file|
        obj = s3.bucket(bucket).object(bucket_folder + File.basename(file))

        obj.upload_file(file)
      end

      # Prune older backups beyond "keep" (days) limit

      log.record('info', 'Pruning older backups on local storage')

      BACKUP_TARGETS.each do |backup_target|
        file_pattern = BACKUP_FILES_DIR + backup_target[:filebase] + '*'
        backup_files = Dir.glob(file_pattern)

        if backup_files.length > backup_target[:keep]
          delete_files = backup_files.sort[0, backup_files.length - backup_target[:keep]]

          delete_files.each { |file| File.delete(file) }
        end
      end

      # Send 'backup successful' notification to Slack
      slack_success_notification(task.name, 'Backup succeeded')

    rescue => err

      slack_fail_notification(task.name, 'Backup raised an error! (')
      log.record('error', "Backup Failed with:\n #{err.message}")

      raise err
    end

  end


end
