class AddWhenApprovedToShfApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :shf_applications, :when_approved, :datetime
  end
end
