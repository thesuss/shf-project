class AddMasterChecklistTypeToMasterChecklist < ActiveRecord::Migration[5.2]

  def change
    add_reference :master_checklists, :master_checklist_type, foreign_key: true, null: false
  end

end
