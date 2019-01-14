# Set the value for shf_application.when_approved
#
# This value needs to be initialized for all ShfApplications that are already
# in the database and approved.
#
# This should have been done in the migration that added the 'when_approved' column to ShfApplication

namespace :shf do
  namespace :one_time do

    desc "Set the ShfApplication when_approved data"
    task set_when_approved_data: :environment do

      log_file = 'log/set_when_approved.log'

      ActivityLogger.open(log_file, 'OneTimeRakeTask', 'set_when_approved_data') do |log|

        approved_apps = User.includes(:shf_application).where.not(shf_application: nil).where(shf_applications: {state: 'accepted'}).distinct
        log.record('info', "Found #{approved_apps.size} approved applications.")

        members_shf_nil_approved_date = approved_apps.select{|m| m.shf_application.when_approved.nil?}
        log.record('info', "Found #{members_shf_nil_approved_date.size} of those with no date for when_approved.")

        members_shf_nil_approved_date.each do | member |
          shf_app = member.shf_application
          last_updated = shf_app.updated_at

          if shf_app.update(when_approved: last_updated)
            log.record('info', "Updated when_approved for id: #{shf_app.id} to #{shf_app.when_approved}")
          else
            log.record('error', "Could not update when_approved for ShfApplication id: #{shf_app.id}. (Tried to update it to #{last_updated}")
          end

        end # members_shf_nil_approved_date.each
      end
    end
  end

end
