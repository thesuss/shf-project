# SHF AWS tasks
#

require 'active_support/logger'

namespace :shf do
  namespace :aws do

    LOGFILENAME = 'SHF_AWS_tasks'
    LOG_FACILITY = 'SHF_TASK'

    # Copy AWS S3 production backups objects
    #  from aws_s3_backup_bucket_name: ENV['SHF_AWS_S3_BACKUP_TOP_PREFIX']/ <source date YYYY-MM-DD>
    #  to aws_s3_backup_bucket_name: ENV['SHF_AWS_S3_BACKUP_TOP_PREFIX']/YYYY/MM/DD
    #
    # We originally backed up to AWS in a new directory (key) each day,
    # where the directory (key) was in the form "YYYY-MM-DD".
    # We are now backing up with nested keys (which looks like nested folders)
    # with the form YYYY/MM/DD
    #
    # Ex: bundle exec rails shf:aws:copy_to_new_prefixes[2021-07-01,2021-08-02]
    #   will copy all objects from /2021-07-01 into /2021/07/01
    #   up to and including all objects from /2021-08-02 into /2021/08/02
    #
    desc 'copy old backups to new prefix names ARGS=[first_date,last_date] first_date and last_date should be date strings in YYYY-MM-DD format  NO SPACES between arguments'
    task :copy_to_new_prefixes, [:first_date, :last_date] => :environment do |_task, args|

      args = args.with_defaults(first_date: '', last_date: '')
      initial_date = validate_date_arg(args[:first_date], 'first_date=')
      final_date = validate_date_arg(args[:last_date], 'last_date=')

      ActivityLogger.open(LogfileNamer.name_for(LOGFILENAME), LOG_FACILITY, 'Copy to new prefixes') do |log|

        aws_s3 = Backup.s3_backup_resource
        aws_s3_backup_bucket_name = Backup.s3_backup_bucket

        source_bucket = aws_s3.bucket(aws_s3_backup_bucket_name)
        destination_bucket = aws_s3.bucket(aws_s3_backup_bucket_name)

        source_prefix = ENV['SHF_AWS_S3_BACKUP_TOP_PREFIX']

        num_days = (final_date - initial_date).to_i + 1
        num_days.to_i.times do |i|
          copy_date = initial_date + i

          source = "#{source_prefix}/#{copy_date.year}-#{copy_date.strftime("%m")}-#{copy_date.strftime("%d")}"
          destination = Backup.s3_backup_bucket_full_prefix(copy_date) # This ends with a '/'

          # Get the names of all objects in the source bucket that start with (have the prefix) source
          source_objs_names = source_bucket.objects(prefix: source).map(&:key)

          # Copy all of the source objects to the destination (uses the target_key as the prefix)
          source_objs_names.each do |source_obj_name|
            # target_key = destination (full prefix) + source_object file name (= the last part of the source_obj_name)
            target_key = "#{destination}#{source_obj_name.split('/').last}"
            source_obj = source_bucket.object(source_obj_name)
            source_obj.copy_to(bucket: destination_bucket.name, key: target_key)
          end

          # show all of the objects at (in) the destination
          dest_objs_names = destination_bucket.objects(prefix: destination).map(&:key)
          log.info "Items copied: #{dest_objs_names}"
        end
      end
    end


    # Apply date tags to objects in the backup bucket. The date tags are based on the date
    # represented by the prefix string.
    # This can be used to apply date tags to objects that were put on AWS before we started
    # doing tagging.
    #
    # Ex:  bundle exec rails shf:aws:apply_date_tags[2021-07-01,2021-09-17]
    #   will apply the default backup tags to every object in /2021/07/01
    #   up to and including the objects in /2021/09/17
    #
    desc 'apply date tags to prefixed backups  ARGS=[first_date,last_date] first_date and last_date should be date strings in YYYY-MM-DD format  NO SPACES between arguments'
    task :apply_date_tags, [:first_date, :last_date] => :environment do |_task, args|

      args = args.with_defaults(first_date: '', last_date: '')
      initial_date = validate_date_arg(args[:first_date], 'first_date=')
      final_date = validate_date_arg(args[:last_date], 'last_date=')

      ActivityLogger.open(LogfileNamer.name_for(LOGFILENAME), LOG_FACILITY, 'Apply date tags') do |log|

        aws_s3 = Backup.s3_backup_resource
        aws_client = aws_s3.client

        aws_s3_backup_bucket_name = Backup.s3_backup_bucket
        source_bucket = aws_s3.bucket(aws_s3_backup_bucket_name)

        num_days = (final_date - initial_date).to_i + 1
        num_days.to_i.times do |i|
          prefix_date = initial_date + i
          full_prefix_for_date = Backup.s3_backup_bucket_full_prefix(prefix_date)
          tags_list = tags_url_str_to_kv_list(Backup.aws_date_tags(prefix_date))

          # Get all of the objects with the prefix and apply the tags
          obj_names = source_bucket.objects(prefix: full_prefix_for_date).map(&:key)

          obj_names.each do |obj_name|
            aws_client.put_object_tagging({ bucket: aws_s3_backup_bucket_name,
                                            key: obj_name,
                                            tagging: { tag_set: tags_list }
                                          })
          end
          log.info("Objects in #{full_prefix_for_date} have been tagged.")
        end
      end

    end

    # ----------------------------------------------

    def validate_date_arg(date_arg, prefix_str = '')
      Date.iso8601(date_arg)
    rescue ArgumentError => error
      log error, "#{prefix_str}'#{date_arg}' is invalid. Must be YYYY-MM-DD Ex: 2021-02-03 (Date.iso8601 valid format)"
      raise error
    end


    # Convert a string of tags in the URL format used when uploading a file
    # to the Hash format expected by Aws::S3::Client#put_object_tagging
    #
    # @return [Array[Hash]] - list of { key: "TagKey", value: "Value"}
    def tags_url_str_to_kv_list(tags_string = '')
      tags_array = tags_string.split('&').map { |t| t.split('=') }
      tags_array.to_h.map { |k, v| { key: k, value: v } }
    end
  end
end

