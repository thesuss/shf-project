class ShfDocumentsController < ApplicationController

  before_action :set_shf_document, only:  [ :show, :edit, :update, :destroy ]
  before_action :authorize_shf_doc, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_shf_doc_class, only: [:index, :new, :create, :historika_meeting_minutes ]


  def index
    # ShfDocument.all
    @ransack_query_results = ShfDocument.ransack(params[:q])
    @shf_documents = @ransack_query_results.result(distinct: true)
  end


  def show
  end


  def new
    @shf_document = ShfDocument.new
    @shf_document.uploader = @current_user
  end


  def edit
  end


  def create
    @shf_document = ShfDocument.new(shf_document_params)

    if @shf_document.save
      redirect_to @shf_document, notice: t('.success', document_title: @shf_document.title)
    else
      render :new, notice: t('.error', document_title: @shf_document.title )
    end

  end


  def update

    if @shf_document.update(shf_document_params)
      redirect_to @shf_document, notice: t('.success', document_title: @shf_document.title )
    else
      render :edit, notice: t('.error', document_title: @shf_document.title )
    end

  end


  def destroy

    @shf_document.destroy

    redirect_to shf_documents_url, notice: t('.success', document_title: @shf_document.title )

  end


  def minutes_and_static_pages
  end


  private

  def authorize_shf_doc_class
    authorize ShfDocument
  end


  def authorize_shf_doc
    authorize @shf_document
  end


  # Use callbacks to share common setup or constraints between actions.
  def set_shf_document
    @shf_document = ShfDocument.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def shf_document_params
    params.require(:shf_document).permit(:uploader_id,
                                         :title,
                                         :description,
                                         :actual_file,
                                         :actual_file_file_name,
                                         :actual_file_file_size,
                                         :actual_file_content_type,
                                         :actual_file_updated_at,
                                         :_destroy
    )
  end


end
