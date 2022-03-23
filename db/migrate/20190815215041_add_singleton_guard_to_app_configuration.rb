class AddSingletonGuardToAppConfiguration < ActiveRecord::Migration[5.2]

  def change
    add_column :app_configurations, :singleton_guard, :integer, default: 0, null: false

    # This index will insure that only 1 record/row can exist:
    add_index :app_configurations, :singleton_guard, unique: true
  end
end
