class ChangeMembershipApplication < ActiveRecord::Migration[5.0]
  def change
    change_table :membership_applications do |t|
      t.remove :company_name, :contact_person, :company_email
      t.string :first_name, :last_name, :contact_email
    end
    add_reference :membership_applications, :business_category, foreign_key: true
  end
end