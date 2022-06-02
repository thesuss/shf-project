class ChangeMembershipUserToPolymorphicOwner < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :memberships, :users

    rename_column :memberships, :user_id, :owner_id # don't drop  this column else we'll lose historical information
    add_column :memberships, :owner_type, :string, default: 'User', null: false

    add_index :memberships, :owner_type
  end
end
