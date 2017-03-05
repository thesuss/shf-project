class UsersController < ApplicationController
  before_action :authorize_user
  before_action :set_user, only: :show


  def index
    @users = User.all.order(last_sign_in_at: :asc)
  end



  private

  def authorize_user
    authorize User
  end

  def set_user
    @user = User.find(params[:id])
  end

end
