class RenameRegionToOldRegion < ActiveRecord::Migration[5.1]
  def change
    rename_column :companies, :region, :old_region
  end
end
