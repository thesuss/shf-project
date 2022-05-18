class CreateCompanyAndCategories < ActiveRecord::Migration[5.2]
  def change
    create_view :company_and_categories, materialized: true

    add_index :company_and_categories, :id
    add_index :company_and_categories, :company_id
    add_index :company_and_categories, :company_number
    add_index :company_and_categories, :category_name
    add_index :company_and_categories, [:company_id, :category_name]
    # add_index :company_and_categories, [:company_number, :category_name]
    add_index :company_and_categories, :category_id
    add_index :company_and_categories, :ancestry

  end
end
