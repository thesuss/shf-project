class CreateJointTableBusinessCategoryMembersipApplication < ActiveRecord::Migration[5.0]
  def change
    create_table :categories_membersip_applications do |t|
      t.belongs_to :membership_applications, index: {name: 'index_on_applications'}
      t.belongs_to :business_categories, index: {name: 'index_on_categories'}
    end
  end
end
