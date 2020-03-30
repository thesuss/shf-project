json.extract! user_checklist, :id, :user_id, :name, :description, :master_checklist_id, :date_completed, :created_at, :updated_at
json.url user_user_checklist_url(user_checklist, format: :json)
