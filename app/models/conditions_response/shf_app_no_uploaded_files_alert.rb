# This emails an applicant if their SHF Application has no uploaded files.
# (Files are needed to show qualifications.)
#
class ShfAppNoUploadedFilesAlert < UserEmailAlert


  # FIXME -- all of these conditional checks need to be put into a Requirements... class
  def send_alert_this_day?(timing, config, user)

    return false unless user.has_shf_application?

    shf_app = user.shf_application
    return false unless shf_app.possibly_waiting_for_upload?

    if shf_app.uploaded_files.empty?

      # If the applicant has said they will email or (postal) mail the files,
      # don't send this alert.

      if shf_app.upload_files_will_be_delivered_later?
        false

      else
        # date that the application was last updated = the day to use ?
        day_to_check = self.class.days_today_is_away_from(shf_app.updated_at.to_date, timing)

        send_on_day_number?(day_to_check, config)
      end

    else  # they did upload some files, so don't send the alert
      false
    end

  end


  def mailer_method
    :app_no_uploaded_files
  end

end
