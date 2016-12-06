class AddCompanyNumberIndexToCompany < ActiveRecord::Migration[5.0]
  def change
    add_index :companies, :company_number, unique: true
  end
end
