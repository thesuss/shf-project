#--------------------------
#
# @class UpdateByTaskNoteFormatter
#
# @desc Responsibility: Create a standardized formatted string for noting that something was updated by a Rake task.
#  This can be used by tasks to append a note to some object so that we can record that the attribute was changed
#  and what the original and new values are.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   4/13/22
#
#--------------------------

module UpdateByTaskNoteFormatter

  def nil_or_str(value)
    value.nil? ? 'nil' : "'#{value}'"
  end

  def update_note(task_name = '', change_note = '')
    return '' if task_name.empty? && change_note.empty?

    "Changed by rake task #{task_name} at #{Time.now.utc} : #{change_note}"
  end


  def entity_attrib_change_note(entity = '', id = '', attribute, original_value, new_value)
    "#{entity}[id: #{id}] #{attribute} changed to #{new_value}.  Original value was #{nil_or_str(original_value)}."
  end

  # Create the complete note based on the original and new values of the attribute
  #
  # @example
  #    create_update_note(:populate_past_payment_amounts, this_payment.class, payment.id, :amount, nil, 30000)
  #    # => "Changed by rake task populate_past_payment_amounts at 2022-04-13 20:12:26 UTC : Payment[id: 851] amount changed to 30000. Original amount was nil."
  #
  def create_update_note(task_name = '', entity = '', id = '', attribute, original_value, new_value)
    update_note(task_name, "#{entity_attrib_change_note(entity, id, attribute, original_value, new_value)}")
  end
end
