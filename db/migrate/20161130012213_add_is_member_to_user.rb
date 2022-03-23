class AddIsMemberToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :is_member, :boolean, :null => false, :default => false
  end
end
