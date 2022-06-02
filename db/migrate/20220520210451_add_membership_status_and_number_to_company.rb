class AddMembershipStatusAndNumberToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :membership_number, :string
    add_index :companies, :membership_number, unique: true

    add_column :companies, :membership_status, :string
    add_index :companies, :membership_status
  end
end
