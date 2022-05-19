module AdminOnly

  class MasterChecklistNotFoundError < StandardError
  end

  class MasterChecklistsController < ApplicationController

    before_action :set_master_checklist, only: [:show, :edit, :update, :destroy, :set_to_no_longer_used]

    before_action :authorize_master_checklist, only: [:update, :show, :edit, :destroy, :set_to_no_longer_used]
    before_action :authorize_master_checklist_class, only: [:index, :index_as_table,
                                                            :new, :create]

    def index
      authorize_master_checklist_class
      @master_checklists = MasterChecklist.in_use
      @no_longer_in_use = MasterChecklist.not_in_use
    end

    def index_as_table
      authorize_master_checklist_class
      @master_checklists = MasterChecklist.all_as_array_nested_by_name
    end

    def show
      @max_list_position_zerobased = max_position_in_this_list(@master_checklist)
      @no_longer_in_use = @master_checklist.children.not_in_use
    end

    def new
      @master_checklist = MasterChecklist.new
      parent_id = params.fetch('parent', false) ? params['parent'].to_i : nil

      @master_checklist.list_position = next_list_position_for(parent_id)
      @master_checklist.parent = MasterChecklist.find(parent_id) if parent_id
      if @master_checklist.parent
        @master_checklist.master_checklist_type = @master_checklist.parent.master_checklist_type
      end

      @max_list_position_zerobased = @master_checklist.list_position
      @all_allowable_parents = all_allowable_parents
    end

    def edit
      @max_list_position_zerobased = max_position_in_this_list(@master_checklist)
      @all_allowable_parents = all_allowable_parents
    end

    def create
      params_with_corrected_list_pos = params_with_corrected_list_pos(master_checklist_params)

      @master_checklist = MasterChecklist.new(params_with_corrected_list_pos)

      insert_into_parent(master_checklist_params)

      respond_to do |format|
        if @master_checklist.save
          format.html { redirect_to @master_checklist, notice: t('.success', name: @master_checklist.name) }
          format.json { render :show, status: :created, location: @master_checklist }
        else
          @all_allowable_parents = all_allowable_parents
          @max_list_position_zerobased = @master_checklist.list_position
          format.html do
            @master_checklist.errors.full_messages.each { |err_message| helpers.flash_message(:alert, err_message) }

            render :new, error: 'Error creating the new MasterChecklist:  '
          end
          format.json { render json: @master_checklist.errors, status: :unprocessable_entity }
        end
      end
    end

    # TODO DRY this up.  specifically: error conditions.
    # FIXME need to warn if there are completed user checklists and ... trying to change fields that cannot be changed if there are already completed items
    def update
      params_with_corrected_list_pos = params_with_corrected_list_pos(master_checklist_params)

      begin

        if @master_checklist.update(params_with_corrected_list_pos)
          respond_to do |format|
            format.html { redirect_to @master_checklist, notice: t('.success', name: @master_checklist.name) }
            format.json { render :show, status: :ok, location: @master_checklist }
          end

        else

          respond_to do |format|

            format.html do
              helpers.flash_message(:alert, t('.error', name: @master_checklist.name))
              @master_checklist.errors.full_messages.each { |err_message| helpers.flash_message(:alert, err_message) }
              render :edit
            end

            format.json { render json: @master_checklist.errors, status: :unprocessable_entity }
          end
        end

        # rescue AdminOnly::HasCompletedUserChecklistsCannotChange => cannot_change_error

      rescue => cannot_change_error

        respond_to do |format|

          format.html do
            changed_attributes = @master_checklist.changed_attributes.keys #.reject { |k, _v| @master_checklist.attributes_can_change_with_completed.include?(k) }
            changed_attributes = changed_attributes.reject { |k, v| @master_checklist.class.attributes_can_change_with_completed.include?(k.to_sym) }

            helpers.flash_message(:alert, t('.error_cant_change_has_completed', name: @master_checklist.name, attributes: changed_attributes.join(', ')))

            @master_checklist.errors.full_messages.each { |err_message| helpers.flash_message(:alert, err_message) }
            redirect_to @master_checklist
          end

          format.json { render json: @master_checklist.errors, status: :unprocessable_entity }
        end

      end

    end

    def destroy
      if @master_checklist.destroy
        respond_to do |format|
          format.html { redirect_to admin_only_master_checklists_path, notice: t('.success', name: @master_checklist.name) }
          format.json { head :no_content }
        end
      else

        respond_to do |format|
          format.html do
            helpers.flash_message(:alert, t('.error', name: @master_checklist.name))
            @master_checklist.errors.full_messages.each { |err_message| helpers.flash_message(:alert, err_message) }
            redirect_to @master_checklist
          end
          format.json { render json: @master_checklist.errors, status: :unprocessable_entity }
        end
      end

    end

    # Set the master checklist to 'no longer in use'
    def set_to_no_longer_used
      if @master_checklist

        if @master_checklist.set_is_in_use(false)
          respond_to do |format|

            # it may have been deleted (if it was allowed to be), or it may have just been set to 'not in use'
            if MasterChecklist.exists?(@master_checklist.id)
              format.html { redirect_to admin_only_master_checklist_path(@master_checklist), notice: t('.success', name: @master_checklist.name) }
              format.json { render :show, status: :ok, location: @master_checklist }
            else
              # it was deleted
              format.html { redirect_to admin_only_master_checklists_path, notice: t('.success', name: @master_checklist.name) }
              format.json { render :index, status: :ok }
            end

          end
        else
          respond_to do |format|
            format.html do
              helpers.flash_message(:alert, t('.error', name: @master_checklist.name))
              #
              # FIXME - need to reinitialze info for the master checklist?  type?
              #
              @master_checklist.errors.full_messages.each { |err_message| helpers.flash_message(:alert, err_message) }
              render :edit
            end
            format.json { render json: @master_checklist.errors, status: :unprocessable_entity }
          end
        end

      else
        raise MasterChecklistNotFoundError, t('.not_found', id: id_only_param[:id])
      end

    end

    # Return the next list position allowed for a MasterChecklist with a given id.
    # This is _not zero based._  The first list position is ONE, not zero
    # If the MasterChecklist cannot be found, return 1.
    #
    # This uses handle_xhr_request and passes in a block to execute (yield) and
    # returns a Hash of information to be merged with the XHR response data.
    #
    # @return [JSON, Nil] - JSON: integer - the number of children for an MasterChecklist.  0 (zero) if there are no children
    def next_one_based_list_position

      handle_xhr_request do

        if params[:id].blank?
          # Get the next position for all TOP LEVEL lists
          { max_position: AdminOnly::MasterChecklist.top_level_next_list_position }

        else
          cmaster_id = params[:id]
          checklist_master = MasterChecklist.find(cmaster_id)

          if checklist_master
            { id: cmaster_id, max_position: checklist_master.next_list_position }
          else
            raise MasterChecklistNotFoundError, t('.not_found', id: cmaster_id)
          end
        end
      end

    end

    # Change the state of is_in_use to it's opposite and the date it was changed (now).
    # This uses handle_xhr_request and passes in a block to execute (yield) and
    # returns a Hash of information to be merged with the XHR response data.
    #
    # TODO This method was used during development, but may no longer be needed. Deleting an item takes the place of this.
    #
    # @return [JSON, Nil] - the value of is_in_use [Boolean] and is_in_use_changed_at: the date this was changed (now)
    def toggle_in_use

      handle_xhr_request do |checklist_master|

        checklist_master.toggle_is_in_use

        # return this hash of information to be returned in the XHR response data:
        { is_in_use: checklist_master.is_in_use,
          is_in_use_changed_at: checklist_master.is_in_use_changed_at }

      rescue AdminOnly::HasCompletedUserChecklistsCannotChange
        raise AdminOnly::HasCompletedUserChecklistsCannotChange, t('.cannot_change_has_completed')

      rescue AdminOnly::CannotChangeUserVisibleInfo
        raise AdminOnly::CannotChangeUserVisibleInfo, t('.cannot_change_user_visible')

      end
    end

    private

    def authorize_master_checklist
      authorize @master_checklist
    end

    def authorize_master_checklist_class
      authorize MasterChecklist
    end

    def set_master_checklist
      @master_checklist = MasterChecklist.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def master_checklist_params
      params.require(:admin_only_master_checklist).permit(:name,
                                                          :displayed_text,
                                                          :description,
                                                          :position,
                                                          :parent_id,
                                                          :list_position,
                                                          :notes,
                                                          :master_checklist_type_id)
    end

    def parent_checklist_param
      params.permit(:parent)
    end

    def id_only_param
      params.require(:id)
    end

    # @return [Array[OrderedListItem]] - list of all OrderedListEntries
    #   that could be a parent to @master_checklist;
    def all_allowable_parents
      @master_checklist.allowable_parents(all_ordered_list_entries)
    end

    def all_ordered_list_entries
      MasterChecklist.all_as_array_nested_by_name
    end

    # Given the parent_id, return the list position for a new master checklist
    # If parent_id is nil,
    #   then return the next position for a list with no parent, which is top level list
    # else look up the parent list with that id
    #   if the parent list was not found,
    #     then return the next position for a list with no parent, which is top level list
    #     else return the next position from the parent list
    #
    def next_list_position_for(parent_id = nil)
      if parent_id
        parent_list = MasterChecklist.find(parent_id)
        parent_list ? parent_list.next_list_position : MasterChecklist.top_level_next_list_position
      else
        MasterChecklist.top_level_next_list_position
      end
    end

    def params_with_corrected_list_pos(checklist_params)
      checklist_params.merge({ list_position: corrected_list_position(checklist_params) })
    end

    # Change the value of the list position to ZERO BASED (subtract 1).
    # Set a default list position if none given:
    #  if there is a parent list,
    #   then the default list position is the next position in the list (ex: a new item is added to the end of a parent list)
    #  else it is zero
    #
    def corrected_list_position(checklist_params)
      default_list_position = 0
      list_position = default_list_position

      if checklist_params.dig('list_position').blank?
        unless checklist_params.dig('parent_id').blank?
          parent_list = MasterChecklist.find(checklist_params.fetch('parent_id', false).to_i)
          list_position = parent_list.next_list_position
        end

      else
        list_position = checklist_params.dig('list_position').to_i - 1
      end

      list_position.to_s
    end

    # FIXME - this returns a mix of last_postion and _next_position.   Pick one.
    def max_position_in_this_list(master_checklist)
      master_checklist.ancestors? ? master_checklist.parent.last_used_list_position : MasterChecklist.top_level_next_list_position
    end

    # Insert this item into a parent is if there is a parent list for this item
    # TODO - does this belong here or in the MasterChecklist?  (or perhaps some of this belongs in MasterChecklist?)
    def insert_into_parent(list_entry_params)

      # if a parent list was specified
      unless list_entry_params.fetch('parent_id', nil).blank?
        parent_list = MasterChecklist.find(master_checklist_params.fetch('parent_id', false).to_i)

        # insert this item in the position specified.  The position of other items may be altered per MasterChecklist behavior
        parent_list.insert(@master_checklist, @master_checklist.list_position)
      end
    end

    # Template method (wrapper) for doing an XHR request.
    # Expects the yeild to return a Hash of information; this Hash will be merged
    # into the response data rendered as JSON and sent back to the XHR requester.
    #
    # TODO - Generalize this so it can be put into ApplicationController and use by other controllers
    #
    def handle_xhr_request
      validate_and_authorize_xhr

      # defaults
      status = XHR_ERROR
      status_text = XHR_ERRORTEXT
      error_text = ''
      additional_response_data = {}

      # if checklist_master
      # begin
      additional_response_data = additional_response_data.merge(yield)

      status = XHR_SUCCESS
      status_text = XHR_SUCCESSTEXT

    rescue => error
      error_text = error.message

    ensure
      response_data = { status: status,
                        status_text: status_text,
                        error_text: error_text }.merge(additional_response_data)

      render json: response_data
    end

    def validate_and_authorize_xhr
      validate_xhr_request
      authorize_master_checklist_class
    end

  end
end
