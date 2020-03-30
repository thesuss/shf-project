require_relative File.join(__dir__, 'data_post_checkbox_helper')

module UserChecklistsHelper

  include DataPostCheckboxHelper

  #
  # @return HTML safe string for a FontAwesome checkbox. Is checked if the user_checklist is complete
  #
  def fa_is_complete_checkbox(user_checklist, options = {})

    checkbox_icon = 'square' # default
    title = "is not completed" # FIXME I18n.t

    if user_checklist.all_completed?
      checkbox_icon = 'check-square'
      title = "is completed"
    end
    html_options = { title: "#{user_checklist.name} #{title}" }.merge(options)

    icon('far', checkbox_icon, html_options)
  end


  # Checkbox for whether or not a UserChecklist is completed.
  #
  # @param [UserChecklist] user_checklist - the user checklist that may or may not be completed
  #
  # @return [String] - html_safe string that is a checkbox with a label for it
  def is_completed_checkbox(user_checklist, options = {})
    checkbox_with_post('completed-checkbox',
                       'checked',
                       user_checklist.all_completed?,
                       user_user_checklist_all_changed_by_completion_toggle_path(user_checklist.user, user_checklist), options)
  end

  # @return [Lambda] - lambda to use to generate the ul element id based on the user_checklist
  def ul_id
    lambda { |user_checklist| "ul-id-#{user_checklist.id}" }
  end


  # @return [Lambda] - lambda to use to generate the li element id based on the user_checklist
  def li_id
    lambda { |user_checklist| "li-id-#{user_checklist.id}" }
  end


end
