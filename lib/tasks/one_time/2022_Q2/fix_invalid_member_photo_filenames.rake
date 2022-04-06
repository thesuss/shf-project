require 'active_support/logger'

namespace :shf do
  namespace :one_time do

    def users_with_invalid_photo_filenames
      invalid_users = User.all.select(&:invalid?).sort_by(&:id)
      invalid_users.select{|iu| iu.errors[:member_photo_file_name].any? }
    end

    BAD_CHAR_REPLACEMENT = '-' unless defined?(BAD_CHAR_REPLACEMENT)

    # Unicodes that are combined with a letter
    # (The resulting string looks like 1 character with a diacritical/accent, but is actually 2 characters.)
    # @url https://www.codetable.net/Group/combining-diacritical-marks
    UMLAUT_CODE = 776  # a.k.a. "diaresis"
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
      fixed_str = fixed_str.tr(UMLAUT_COMBINED,'')
      fixed_str = fixed_str.tr(RING_COMBINED,'')
      fixed_str = fixed_str.tr(A_RING_LCASE,'a')
      fixed_str = fixed_str.tr(A_RING_UPCASE,'A')
      fixed_str = fixed_str.tr(A_UMLAUT_LCASE,'a')
      fixed_str = fixed_str.tr(A_UMLAUT_UPCASE,'A')
      fixed_str = fixed_str.tr(O_UMLAUT_LCASE,'o')
      fixed_str.tr(O_UMLAUT_UPCASE,'O')
    end

    def fix_invalid_photo_fn(invalid_fn)
      fixed_diacriticals = fix_diacritical_chars(invalid_fn)

      # filename base is everything except the extension (including the '.' for the extension)
      base_ext_regexp = Regexp.new('(.+)(\.png|\.jpe?g)', Regexp::IGNORECASE)
      match = fixed_diacriticals.match(base_ext_regexp)
      base = match[1]
      extension = match[2]
      "#{ base.gsub(/\W/,BAD_CHAR_REPLACEMENT)}#{extension}"
    end

    desc 'fix invalid member photo file names'
    task fix_invalid_member_photo_file_names: [:environment] do |this_task|
      task_name_end = this_task.to_s.split(':').last # the task name without the namespace(s)
      log_msg_starter = 'Fix invalid member photo file names'

      ActivityLogger.open(LogfileNamer.name_for("SHF-one-time-task-#{task_name_end}"), 'OneTimeRakeTask', task_name_end) do |log|
        log.info(log_msg_starter)
        begin
          num_users_changed = 0
          users_with_invalid_photo_filenames.each do |user_with_invalid_fn|
            if user_with_invalid_fn.member_photo_file_name.present?
              old_fn = user_with_invalid_fn.member_photo_file_name.dup
              valid_fn = fix_invalid_photo_fn(user_with_invalid_fn.member_photo_file_name)
              user_with_invalid_fn.update!(member_photo_file_name: valid_fn)
              log.info(" User[#{user_with_invalid_fn.id}] #{user_with_invalid_fn.email}: original invalid member photo filename: #{old_fn}; new fixed filename: #{valid_fn}")
              num_users_changed += 1
            end
          end
          log.info(" #{num_users_changed} Users updated")

        rescue => error
          error_message = ">> ERROR! Could not change photo file name: #{error.message}\n #{error.backtrace.join("\n")}"
          log.error error_message
          raise error, error_message
        end

        log.info("\n#{log_msg_starter} successful and complete.")
      end
    end

  end
end
