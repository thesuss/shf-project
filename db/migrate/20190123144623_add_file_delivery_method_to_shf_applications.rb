class AddFileDeliveryMethodToShfApplications < ActiveRecord::Migration[5.2]
  def change
    add_reference :shf_applications, :file_delivery_method, foreign_key: true
    add_column :shf_applications, :file_delivery_selection_date, :date
  end
end
