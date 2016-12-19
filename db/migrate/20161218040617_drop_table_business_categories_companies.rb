class DropTableBusinessCategoriesCompanies < ActiveRecord::Migration[5.0]
  def change
    drop_join_table :business_categories, :companies
  end
end
