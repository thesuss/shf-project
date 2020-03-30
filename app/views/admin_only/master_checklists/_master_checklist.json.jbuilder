json.extract! master_checklist, :id, :name, :displayed_text, :description, :list_position, :is_in_use, :is_in_use_changed_at, :parent.id, :created_at, :updated_at
json.url admin_only_master_checklist_url(master_checklist, format: :json)
