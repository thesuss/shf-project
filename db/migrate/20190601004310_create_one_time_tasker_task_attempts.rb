class CreateOneTimeTaskerTaskAttempts < ActiveRecord::Migration[5.2]
  def change
    create_table :one_time_tasker_task_attempts do |t|
      t.string :task_name, null: false
      t.string :task_source
      t.timestamp :attempted_on, null: false
      t.boolean :was_successful, null: false, default: false
      t.string :notes, null: true

      t.timestamps
    end
  end
end
