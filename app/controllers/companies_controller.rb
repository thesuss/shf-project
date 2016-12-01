class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update]
  before_action :authorize_company, only: [:update, :show, :edit]


  def index
    authorize Company
    @companies = Company.all
  end


  def show
    @categories = @company.business_categories
  end


  def new
    authorize Company
    @company = Company.new
    @business_categories = BusinessCategory.all
  end


  def edit
    @business_categories = BusinessCategory.all
  end


  def create
    authorize Company
    @company = Company.new(company_params)

    if @company.save
      redirect_to @company, notice: 'The company was successfully created.'
    else
      flash[:alert] = 'A problem prevented the company from being created.'
      render :new
    end
  end


  def update
    if @company.update(company_params)
      redirect_to @company, notice: 'The company was successfully updated.'
    else
      flash[:alert] = 'A problem prevented the company from being updated.'
      render :edit
    end

  end



  private
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def company_params
    params.require(:company).permit(:name, :company_number, :phone_number, :email, :street, :post_code, :city, :region, :website, {business_category_ids: []})
  end

  def authorize_company
    authorize @company
  end
end
