module AdminOnly


  class MasterChecklistTypesController < ApplicationController

    before_action :set_admin_only_master_checklist_type, only: [:show, :edit, :update, :destroy]

    before_action :authorize_master_checklist_type, only: [:update, :show, :edit, :destroy]
    before_action :authorize_master_checklist_type_class, only: [:index, :new, :create]


    def index
      @admin_only_master_checklist_types = AdminOnly::MasterChecklistType.all
    end


    def show
    end


    def new
      @admin_only_master_checklist_type = AdminOnly::MasterChecklistType.new
    end


    def edit
    end


    def create
      @admin_only_master_checklist_type = AdminOnly::MasterChecklistType.new(admin_only_master_checklist_type_params)

      respond_to do |format|
        if @admin_only_master_checklist_type.save

          format.html { redirect_to @admin_only_master_checklist_type, notice: t('.success', name: @admin_only_master_checklist_type.name) }
          format.json { render :show, status: :created, location: @admin_only_master_checklist_type }
        else
          format.html do
            @admin_only_master_checklist_type.errors.full_messages.each { |err_message| helpers.flash_message(:alert, err_message) }
            render :new, error: 'Error creating the new Master Checklist Type: '
          end

          format.json { render json: @admin_only_master_checklist_type.errors, status: :unprocessable_entity }
        end
      end
    end


    def update
      respond_to do |format|
        if @admin_only_master_checklist_type.update(admin_only_master_checklist_type_params)
          format.html { redirect_to @admin_only_master_checklist_type, notice: t('.success', name: @admin_only_master_checklist_type.name) }
          format.json { render :show, status: :ok, location: @admin_only_master_checklist_type }
        else
          format.html { render :edit }
          format.json { render json: @admin_only_master_checklist_type.errors, status: :unprocessable_entity }
        end
      end
    end


    def destroy
      @admin_only_master_checklist_type.destroy
      respond_to do |format|
        format.html { redirect_to admin_only_master_checklist_types_url, notice: t('.success', name: @admin_only_master_checklist_type.name) }
        format.json { head :no_content }
      end
    end


    # -------------------------------------------------------------------------------------

    private


    def authorize_master_checklist_type
      authorize @admin_only_master_checklist_type
    end


    def authorize_master_checklist_type_class
      authorize MasterChecklistType
    end


    def set_admin_only_master_checklist_type
      @admin_only_master_checklist_type = AdminOnly::MasterChecklistType.find(params[:id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_only_master_checklist_type_params
      params.require(:admin_only_master_checklist_type).permit(:name, :description)
    end
  end

end
