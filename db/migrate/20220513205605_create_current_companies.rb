class CreateCurrentCompanies < ActiveRecord::Migration[5.2]
  def change
    create_view :current_companies, materialized: true

    add_index :current_companies, :company_id
    add_index :current_companies, :company_number
    add_index :current_companies, :name
  end
end
