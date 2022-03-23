class AddMembershipGuidelineListToApplicationConfiguration < ActiveRecord::Migration[5.2]

  def change
    add_reference :app_configurations, :membership_guideline_list, foreign_key: {to_table: :master_checklists}
  end
end
