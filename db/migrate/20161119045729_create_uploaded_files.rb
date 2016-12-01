class CreateUploadedFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :uploaded_files do |t|
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
