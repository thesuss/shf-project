class ChangeConfigDefaultInCondition < ActiveRecord::Migration[5.2]

  def change

    # Ensure any conditions with a nil configuration is initialized to an empty Hash
    Condition.all.each do | condition |
      if condition.config.nil?
        condition.config = {}
        condition.save!
      end
    end

    change_column_comment :conditions, :class_name, 'name of the Condition class of this condition (required)'
    change_column_null :conditions, :class_name, false

    change_column_comment :conditions, :config, 'a serialize Hash with configuration information (required; must be a Hash)'
    change_column_default :conditions, :config, from: nil, to: '--- {}'  # this is how an empty Hash is serialized with YAML

    change_column_comment :conditions, :timing, '(optional) specific timing about the Condition'
  end

end
