module AdminOnly

  class UserAccountController < ApplicationController

    include SetAppConfiguration

    before_action :authorize_admin
    before_action :get_user
    before_action :set_app_config, only: [:edit, :update]


    def edit
    end


    def update
      if @user.update(user_account_params)
        redirect_to @user, notice: t('.success')
      else
        helpers.flash_message(:alert, t('.error'))

        @user.errors.full_messages.each { |err_message| helpers.flash_message(:alert, err_message) }

        render :show
      end
    end


    private

    def authorize_admin
      authorize AdminOnly::UserAccount
    end


    def get_user
      @user = User.find(params[:user_id])
    end


    def user_account_params

      # if membership_number is blank then set to nil.
      # The User model allows for blank membership_number.
      # However, the DB (PG) has a unique constraint on this attribute and
      # hence will raise an exception if the attribute is an empty string
      # (one of which will already exist in the DB).
      # Since that exception occurs after model validation, the "update" method
      # cannot rescue this exception. (the DB considers "NULL" values unequal,
      # so "nil" will not trigger the exception on save.)

      if params[:user][:membership_number].blank?
        params[:user][:membership_number] = nil
      end

      params.require(:user)
          .permit(:membership_number,
                  :date_membership_packet_sent)
    end

  end
end
