class CreateShfDocuments < ActiveRecord::Migration[5.0]

  def change

    create_table :shf_documents do |t|
      t.belongs_to :uploader,  null: false, foreign_key: { to_table: :users }
      t.string :title
      t.text :description

      t.timestamps
    end

  end

end
