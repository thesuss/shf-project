class AddAncestryToBusinessCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :business_categories, :ancestry, :string
    add_index :business_categories, :ancestry
  end
end
