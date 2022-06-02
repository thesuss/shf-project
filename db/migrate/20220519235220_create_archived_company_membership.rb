class CreateArchivedCompanyMembership < ActiveRecord::Migration[5.2]
  def change
    create_table :archived_company_memberships do |t|
      t.references :owner,  polymorphic: true, default: Company, index: { name: "archd_co_mships_index_owner_id_type" }
      t.string :member_number
      t.date :first_day, null: false
      t.date :last_day, null: false
      t.string :notes
      t.string :belonged_to_name, null: false
      t.string :belonged_to_email, null: false

      t.timestamps
    end

    add_index :archived_company_memberships, :first_day
    add_index :archived_company_memberships, :last_day
    add_index :archived_company_memberships, :belonged_to_name
    add_index :archived_company_memberships, :belonged_to_email
  end
end
