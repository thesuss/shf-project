class CreateApplicationCompanyJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :shf_applications, :companies do |t|
      t.index [:shf_application_id, :company_id],
              name: 'index_application_company'
      t.index [:company_id, :shf_application_id],
              name: 'index_company_application'
    end
  end
end
