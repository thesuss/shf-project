class ChangeStateDefaultInMembershipApplication < ActiveRecord::Migration[5.0]
  def change

    change_column_default :membership_applications, :state, from: 'Pending', to: 'under_review'

  end
end
