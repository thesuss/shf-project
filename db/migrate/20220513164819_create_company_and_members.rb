class CreateCompanyAndMembers < ActiveRecord::Migration[5.2]
  def change
    create_view :company_and_members,  materialized: true
    # The view definition is in db/views/company_and_members_vnn.sql where "nn" is the version number (per the Scenic gem)

    add_index :company_and_members, :user_id
    add_index :company_and_members, :email
    add_index :company_and_members, [:email, :company_id]
    add_index :company_and_members, :company_id
    add_index :company_and_members, :company_number
    add_index :company_and_members, [:user_id, :company_number]
  end
end
