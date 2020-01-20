class CreateMasterChecklists < ActiveRecord::Migration[5.2]

  def change
    create_table :master_checklists do |t|
      t.string :name, null: false, comment: 'This is a shortened way to refer to the item.'
      t.string :displayed_text, null: false, comment: 'This is what users see'
      t.string :description
      t.integer :list_position, default: 0, null: false, comment: 'This is zero-based. It is the order (position) that this item should appear in its checklist'
      t.string :ancestry
      t.string :notes, comment: 'Notes about this item.'

      t.timestamps
    end

    add_index :master_checklists, :ancestry
    add_index :master_checklists, :name
  end
end
