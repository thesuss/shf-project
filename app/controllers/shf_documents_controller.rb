class ShfDocumentsController < ApplicationController

  before_action :set_shf_document, only:  [ :show, :edit, :update, :destroy ]
  before_action :authorize_shf_doc, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_shf_doc_class,
                  only: [:index, :new, :create,
                         :contents_show, :contents_edit, :contents_update]


  def index
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

  def contents_show
    page_and_page_contents
  end

  def contents_edit
    Ckeditor::Picture.images_category = 'member_pages'
    Ckeditor::Picture.for_company_id = nil

    page_and_page_contents
  end

  def contents_update
    page, file_path = page_and_file_path

    contents = params[:contents]
    File.open(file_path, 'w') do |file|
      file.write(contents)
    end

    member_page = MemberPage.find_by filename: page
    member_page.update_attribute(:title, params[:title])

    redirect_to contents_show_path(page),
                notice: t('.success', document_title: member_page.title)

  rescue => e
    helpers.flash_message(:alert,
                          t('shf_documents.contents_access_error',
                            message: e.message))
    redirect_to member_pages_path
  end


  private

  def page_and_file_path
    page = params[:page]

    file_path = page_path(page) + '.html'

    file_path.sub!('/en/', '') # strip locale prefix if present

    [ page, File.join(Rails.root, 'app', 'views', file_path) ]
  end

  def page_and_page_contents
    @page, file_path = page_and_file_path
    @contents = File.new(file_path).read
    @title = MemberPage.title(@page)
  rescue => e
    helpers.flash_message(:alert,
                          t('shf_documents.contents_access_error',
                            message: e.message))
    redirect_to member_pages_path
  end

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
                                         :_destroy,
                                         :page
    )
  end


end
