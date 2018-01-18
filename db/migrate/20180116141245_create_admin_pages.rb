class CreateAdminPages < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_pages do |t|
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        add_attachment :admin_pages, :chair_signature
        add_attachment :admin_pages, :shf_logo
      end

      dir.down do
        remove_attachment :admin_pages, :chair_signature
        remove_attachment :admin_pages, :shf_logo
      end
    end
  end
end
