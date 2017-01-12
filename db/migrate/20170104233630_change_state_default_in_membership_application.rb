class ChangeStateDefaultInMembershipApplication < ActiveRecord::Migration[5.0]
  def change

    change_column_default :membership_applications, :state, from: 'Pending', to: 'under_review'

    MembershipApplication.where(state: 'Pending').find_each do |pending_app|
      pending_app.state = 'under_review'
      pending_app.save
    end
  end
end
