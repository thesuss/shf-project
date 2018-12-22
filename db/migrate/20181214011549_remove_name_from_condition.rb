class RemoveNameFromCondition < ActiveRecord::Migration[5.2]

  def change

    remove_column :conditions, :name

  end

end
