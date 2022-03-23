class AddHbrandToAppConfiguration < ActiveRecord::Migration[5.1]
  def change

    reversible do |dir|
      dir.up do
        add_attachment :app_configurations, :h_brand_logo
        add_attachment :app_configurations, :sweden_dog_trainers
      end

      dir.down do
        remove_attachment :app_configurations, :h_brand_logo
        remove_attachment :app_configurations, :sweden_dog_trainers
      end
    end
  end
end
