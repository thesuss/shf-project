require 'active_support/logger'

namespace :shf do
  namespace :one_time do

    BAD_CHAR_REPLACEMENT = '-' unless defined?(BAD_CHAR_REPLACEMENT)

    # Unicodes that are combined with a letter
    # (The resulting string looks like 1 character with a diacritical/accent, but is actually 2 characters.)
    # @url https://www.codetable.net/Group/combining-diacritical-marks
    UMLAUT_CODE = 776 # a.k.a. "diaresis"
    RING_CODE = 778
    UMLAUT_COMBINED = '' << UMLAUT_CODE
    RING_COMBINED = '' << RING_CODE

    A_RING_LCASE = 'å'
    A_RING_UPCASE = 'Å'
    A_UMLAUT_LCASE = 'ä'
    A_UMLAUT_UPCASE = 'Ä'
    O_UMLAUT_LCASE = 'ö'
    O_UMLAUT_UPCASE = 'Ö'

    # Replace all diacritical chars (characters that look like they have an accent mark)
    # with non-diacritical (non-accented) characters
    #
    # @param [String] original_str - the String to search and replace
    # @return [String] - A string with all diacritical characters replaces with non-diacritical characters
    def fix_diacritical_chars(original_str)
      fixed_str = original_str
      fixed_str = fixed_str.tr(UMLAUT_COMBINED, '')
      fixed_str = fixed_str.tr(RING_COMBINED, '')
      fixed_str = fixed_str.tr(A_RING_LCASE, 'a')
      fixed_str = fixed_str.tr(A_RING_UPCASE, 'A')
      fixed_str = fixed_str.tr(A_UMLAUT_LCASE, 'a')
      fixed_str = fixed_str.tr(A_UMLAUT_UPCASE, 'A')
      fixed_str = fixed_str.tr(O_UMLAUT_LCASE, 'o')
      fixed_str.tr(O_UMLAUT_UPCASE, 'O')
    end

    def fix_invalid_photo_fn(invalid_fn)
      fixed_diacriticals = fix_diacritical_chars(invalid_fn)

      # filename base is everything except the extension (including the '.' for the extension)
      base_ext_regexp = Regexp.new('(.+)(\.png|\.jpe?g)', Regexp::IGNORECASE)
      match = fixed_diacriticals.match(base_ext_regexp)
      base = match[1]
      extension = match[2]
      "#{ base.gsub(/\W/, BAD_CHAR_REPLACEMENT)}#{extension}"
    end

    def users_with_invalid_photo_filenames
      invalid_users = User.all.select(&:invalid?).sort_by(&:id)
      invalid_users.select { |iu| iu.errors[:member_photo_file_name].any? }
    end

    desc 'fix invalid member photo file names'
    task fix_invalid_member_photo_file_names: [:environment] do |this_task|
      task_name_end = this_task.to_s.split(':').last # the task name without the namespace(s)
      log_msg_starter = 'Fix invalid member photo file names'

      ActivityLogger.open(LogfileNamer.name_for("SHF-one-time-task-#{task_name_end}"), 'OneTimeRakeTask', task_name_end) do |log|
        log.info(log_msg_starter)
        begin
          num_users_changed = 0
          errors = []
          users_with_invalid_photo_filenames.each do |user_with_invalid_fn|
            user_with_invalid_fn.reload
            if user_with_invalid_fn.member_photo_file_name.present?

              attachment = user_with_invalid_fn.member_photo
              old_fn = user_with_invalid_fn.member_photo_file_name.dup
              new_valid_fn = fix_invalid_photo_fn(user_with_invalid_fn.member_photo_file_name)

              unless old_fn == new_valid_fn
                # All attachment styles + the original attachment
                (attachment.styles.keys + [:original]).each do |style|
                  old_fullpath = attachment.path(style)
                  new_fullpath = File.join(File.dirname(old_fullpath), new_valid_fn)
                  # Note that if you are using some other storage file system (e.g. AWS S3)
                  #   you may need to use methods specific to the storage file system.
                  #   Ex: for AWS @see https://github.com/tclaus/Rename-S3-assets-after-paperclip-hashing/blob/master/aws.rake
                  #       or @see https://stackoverflow.com/a/38716353/661471  (Stack Overflow answer specific to AWS)
                  FileUtils.move(old_fullpath, new_fullpath) unless old_fullpath == new_fullpath # just in case this has been run before or doesn't need to happen
                end
                user_with_invalid_fn.member_photo_file_name = new_valid_fn
                user_with_invalid_fn.save!
                log.info(" User[#{user_with_invalid_fn.id}] #{user_with_invalid_fn.email}: original invalid member photo filename: #{old_fn}; new fixed filename: #{new_valid_fn}")
                num_users_changed += 1
              end

            end

          rescue => error
            error_message = ">> ERROR! Could not change photo file name: #{error.message}}"
            log.error error_message
            errors << error_message
            next
          end
          log.info(" #{num_users_changed} Users updated")
          log.info(" #{errors.count} not changed (errors encountered)")

        rescue => unrecoverable_error
          error_message = ">> ERROR!!  #{unrecoverable_error.message}\n #{error.backtrace.join("\n")}"
          log.error error_message
          raise unrecoverable_error, error_message
        end
        log.info("\n#{log_msg_starter} successful and complete.")
      end
    end

    desc 'restore invalid photo filenames to users'
    task restore_invalid_photo_filenames: [:environment] do |this_task|
      task_name_end = this_task.to_s.split(':').last # the task name without the namespace(s)
      log_msg_starter = 'restore invalid member photo file names'

      users_and_invalid_fns =
        [{ id: 31, :invalid_photo_fn => "kicki_fotograf_Björn_Gustafsson.jpg" },
         { :id => 70, :invalid_photo_fn => "Skärmavbild_2018-04-22_kl._18.07.47.png" },
         { :id => 167, :invalid_photo_fn => "IMG_3444_(2)E.jpg" },
         { :id => 192, :invalid_photo_fn => "Jenny.Afvander-stor.jpg" },
         { :id => 206, :invalid_photo_fn => "2016-03-24_12.16.58.jpg" },
         { :id => 322, :invalid_photo_fn => "2015-10-10_11.32.12.jpg" },
         { :id => 347, :invalid_photo_fn => "HelenaNärbild_preview.jpeg" },
         { :id => 361, :invalid_photo_fn => "Skanning_20190605_(3).jpg" },
         { :id => 378, :invalid_photo_fn => "StinaLundinHundKanalen3-225x300_(1).png" },
         { :id => 397, :invalid_photo_fn => "Johanna_Hmärke.jpg" },
         { :id => 417, :invalid_photo_fn => "tö.jpg" },
         { :id => 479, :invalid_photo_fn => "2016-03-13_106_(2).JPG" },
         { :id => 483, :invalid_photo_fn => "Screen_Shot_2018-11-22_at_10.53.27.png" },
         { :id => 485, :invalid_photo_fn => "Skärmavbild_2018-11-13_kl._12.27.10.png" },
         { :id => 569, :invalid_photo_fn => "IMG_9699_(2).JPG" },
         { :id => 587, :invalid_photo_fn => "hund2_-_Copy_(2).jpg" },
         { :id => 643, :invalid_photo_fn => "ulrika_närbild_2.jpg" },
         { :id => 666, :invalid_photo_fn => "Körkort-bakgrund.jpg" },
         { :id => 730, :invalid_photo_fn => "Final_h_märkt_.JPG" },
         { :id => 767, :invalid_photo_fn => "HMS_LR.1-2.jpg" },
         { :id => 769, :invalid_photo_fn => "Skärmavbild_2020-08-20_kl._07.41.36.png" },
         { :id => 770, :invalid_photo_fn => "Imsan..jpg" },
         { :id => 775,
           :invalid_photo_fn =>
             "12291668_10153836352915337_2293732388006327315_o_(2).jpg" },
         { :id => 816, :invalid_photo_fn => "Skärmavbild_2020-12-09_kl._19.47.19.png" },
         { :id => 846, :invalid_photo_fn => "J___M_Bröllop-19.jpg" },
         { :id => 850, :invalid_photo_fn => "Närbild_mer_allvarlig.png" },
         { :id => 863, :invalid_photo_fn => "Foto_Annika_Hmärkt_paint.jpg" },
         { :id => 864, :invalid_photo_fn => "LOGGA_(2).jpg" },
         { :id => 899, :invalid_photo_fn => "Anneli_(1).jpg" },
         { :id => 936, :invalid_photo_fn => "IMG_0426_(1).jpg" },
         { :id => 951, :invalid_photo_fn => "Foto_på_mig.png" }]

      ActivityLogger.open(LogfileNamer.name_for("SHF-one-time-task-#{task_name_end}"), 'OneTimeRakeTask', task_name_end) do |log|
        log.info(log_msg_starter)
        begin
          num_users_changed = 0
          errors = []

          users_and_invalid_fns.each do |u_and_fn|
            sql = "UPDATE users SET member_photo_file_name='#{u_and_fn[:invalid_photo_fn]}' WHERE users.id = #{u_and_fn[:id]}"
            User.connection.execute(sql)
            num_users_changed += 1
          end
        rescue => unrecoverable_error
          error_message = ">> ERROR!!  #{unrecoverable_error.message}\n #{error.backtrace.join("\n")}"
          log.error error_message
          raise unrecoverable_error, error_message
        end

        log.info(" #{num_users_changed} Users updated")
        log.info(" #{errors.count} not changed (errors encountered)")
      end

    end
  end
end
