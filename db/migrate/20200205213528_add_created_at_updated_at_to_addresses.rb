class AddCreatedAtUpdatedAtToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :created_at, :timestamp
    add_column :addresses, :updated_at, :timestamp
  end
end
