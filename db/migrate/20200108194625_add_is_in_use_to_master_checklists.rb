class AddIsInUseToMasterChecklists < ActiveRecord::Migration[5.2]
  def change
    add_column :master_checklists, :is_in_use, :boolean, default: true, null: false
    add_column :master_checklists, :is_in_use_changed_at, :timestamp
  end
end
