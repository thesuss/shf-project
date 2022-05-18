class CreateMemberAndCategories < ActiveRecord::Migration[5.2]
  def change
    create_view :member_and_categories, materialized: true

    add_index :member_and_categories, :id
    add_index :member_and_categories, :user_id
    add_index :member_and_categories, :category_name
    add_index :member_and_categories, [:category_name, :user_id]
    add_index :member_and_categories, :category_id
    add_index :member_and_categories, :ancestry
    add_index :member_and_categories, [:category_name, :application_id]
  end
end
