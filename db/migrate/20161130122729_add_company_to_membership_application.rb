class AddCompanyToMembershipApplication < ActiveRecord::Migration[5.1]
  def change
    add_reference :membership_applications, :company, index: true, null: true
  end
end
