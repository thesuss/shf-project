class CreateCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :companies do |t|
      
      t.string :name
      t.string :phone_number
      t.string :email
      t.string :street
      t.string :post_code
      t.string :city
      t.string :region
      t.string :website
      t.string :social1
      t.string :social2
      t.string :social3

      t.references :user, index: true, foreign_key: true

      t.timestamps
    end
  end
end
