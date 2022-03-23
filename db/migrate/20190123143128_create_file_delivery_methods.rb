class CreateFileDeliveryMethods < ActiveRecord::Migration[5.2]
  def change
    create_table :file_delivery_methods do |t|
      t.string :name, null: false
      t.string :description_sv
      t.string :description_en
      t.boolean :default_option, default: false

      t.timestamps
    end

    add_index(:file_delivery_methods, :name, unique: true)

    change_table_comment(:file_delivery_methods,
      'User choices for how files for SHF application will be delivered')
  end
end
