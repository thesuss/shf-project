class CreateAppConfigurations < ActiveRecord::Migration[5.1]
  def change
    create_table :app_configurations do |t|
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        add_attachment :app_configurations, :chair_signature
        add_attachment :app_configurations, :shf_logo
      end

      dir.down do
        remove_attachment :app_configurations, :chair_signature
        remove_attachment :app_configurations, :shf_logo
      end
    end
  end
end
