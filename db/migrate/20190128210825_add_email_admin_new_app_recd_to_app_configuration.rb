class AddEmailAdminNewAppRecdToAppConfiguration < ActiveRecord::Migration[5.2]
  def change
    add_column :app_configurations, :email_admin_new_app_received_enabled, :boolean, default: true
  end
end
