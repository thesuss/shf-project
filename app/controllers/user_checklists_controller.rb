class UserChecklistControllerError < StandardError
end
class MissingUserChecklistParameterError < UserChecklistControllerError
end
class UserChecklistNotFoundError < UserChecklistControllerError
end

#
# Note that there are NO new, create, edit, update, or destroy actions.
# A user cannot create a new checklist, nor can a user edit one or destroy one.
# Nor can an admin create a new one or edit one manually or destroy one
#

class UserChecklistsController < ApplicationController


  def index
    authorize_user_checklist_class

    # Get all the checklists for the user in the path. Ex: If the current user is an admin,
    # then we want to be sure to see the checklists for a specific user, not for the admin.
    @user = current_user.admin? ? User.find(params[:user_id]) : current_user

    found_lists = UserChecklist.where(user: @user) #.includes(:master_checklist)
    @user_checklists = found_lists.blank? ? [] : found_lists
  end


  def show
    set_user_checklist
    authorize_user_checklist
  end


  def show_progress
    @user = User.find(progress_params[:user_id])

    @user_checklist = UserChecklist.find(progress_params[:user_checklist_id])
    authorize_user_checklist
    @checklist_root = @user_checklist.root
    @overall_progress = @checklist_root.percent_complete
    if @overall_progress == 100
      # set the root to complete?
      render :membership_guidelines_completed # TODO revise the partial: generalize to work for any User checklist
    end
  end


  # (XHR request)
  # Toggle the date_completed for the checklist, then update all lists that
  # need to be changed because of it.
  #
  # Return data for all of the checklists that had to be changed:
  #  the updated date_completed and percent complete.
  #
  def all_changed_by_completion_toggle
    handle_xhr_request do
      raise MissingUserChecklistParameterError, t('.missing-checklist-param-error') if params[:user_checklist_id].blank?

      user_checklist_id = params[:user_checklist_id]
      user_checklist = UserChecklist.find(user_checklist_id)
      raise ActiveRecord::RecordNotFound, t('.not_found', id: user_checklist_id) if user_checklist.nil?

      # toggle the date_completed and get the list of all those changed
      checklists_changed = user_checklist.all_changed_by_completion_toggle

      changed_checklists.concat(checklists_changed.map do |checklist_changed|
        # use just the Date, not the time
        date_complete = checklist_changed.date_completed.nil? ? nil : checklist_changed.date_completed.to_date
        { checklist_id: checklist_changed.id,
          date_completed: date_complete,
          overall_percent_complete: checklist_changed.root.percent_complete
        }
      end)

      { changed_checklists: changed_checklists }
    end
  end


  # Set the given UserChecklist to completed (date_completed = Time.zone.now) and
  # set all of its descendants to completed, too.
  #
  # @return [Hash] - the id of the UserChecklist changed (the parent),
  #                  the new date_completed value for it,
  #                  and the new overall percent complete value (for the top-level ancestor of the user_checklist)
  #
  def set_complete_including_kids
    handle_xhr_request do
      set_uc_and_kids_date_completed(params, Time.zone.now)
    end
  end


  def set_uncomplete_including_kids
    handle_xhr_request do
      set_uc_and_kids_date_completed(params, nil)
    end
  end


  private


  def set_user_checklist
    @user_checklist = UserChecklist.includes(:user).find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def user_checklist_params
    params.require(:user_checklist).permit(:master_checklist, :user_id,
                                           :name, :description, :list_position, :date_completed)
    params
  end


  def progress_params
    params.require(:user_checklist_id)
    params
  end


  def authorize_user_checklist
    authorize @user_checklist
  end


  def authorize_user_checklist_class
    authorize UserChecklist
  end


  # @return [Hash] - a simple hash with the checklist id and date_completed
  def hash_id_date_completed(checklist)
    # use just the Date, not the time
    date_complete = checklist.date_completed.nil? ? nil : checklist.date_completed.to_date
    { checklist_id: checklist.id, date_completed: date_complete }
  end


  def set_uc_and_kids_date_completed(action_params, new_date_completed = Time.zone.now)

    raise MissingUserChecklistParameterError, t('.missing-checklist-param-error') if action_params[:id].blank?

    user_checklist_id = action_params[:id]
    user_checklist = UserChecklist.find(user_checklist_id)

    if user_checklist
      if new_date_completed
        user_checklist.set_complete_including_children(new_date_completed)
      else
        user_checklist.set_uncomplete_including_children
      end
      new_percent_complete = user_checklist.root.percent_complete

      { user_checklist_id: user_checklist_id,
        date_completed: user_checklist.date_completed,
        overall_percent_complete: new_percent_complete }

    else
      raise UserChecklistNotFoundError, t('.not_found', id: user_checklist_id)
    end

  end


  # TODO - this should be from AppConfiguration
  def membership_guideline_root_user_checklist(uc_user)
    UserChecklist.find_by(name: 'Medlemsåtagande', user: uc_user)
  end


  def validate_and_authorize_xhr
    validate_xhr_request
    authorize_user_checklist_class
  end

end
