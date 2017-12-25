module AdminOnly

  class DashboardController < ApplicationController

    before_action :authorize_dashboard



    def index
      @total_members = User.members.count

      # Membership applications by state
      @app_state_counts = {}

      ShfApplication.all_states.each do | app_state |
          @app_state_counts[app_state] = ShfApplication.total_in_state app_state
      end

      @apps_approved_member_fee_not_paid = User.all.select(&:member_fee_payment_due?)
      @companies_branding_not_paid = Company.all.reject(&:branding_license?)
      @companies_info_not_completed =  Company.all - Company.complete

      @daterange_end = Time.zone.now
      @daterange_start = @daterange_end - 7.days

      @member_fee_payments = Payment.member_fee.where( status: 'betald', updated_at: @daterange_start..@daterange_end)
      @branding_fee_payments = Payment.branding_fee.where( status: 'betald', updated_at: @daterange_start..@daterange_end)

    end


    def show
    end



    private


    # Never trust parameters from the scary internet, only allow the white list through.
    def dashboard_params
      params.require(:admin_only_dashboard).permit(:name_sv, :description_sv, :name_en, :description_en, :is_custom)
    end

    def self.policy_class
      AdminOnly::DashboardPolicy
    end

    # manually set and check the pundit policy because the default Pundit policy finder chokes on this (we do not have a 'Dashboard' class)
    def authorize_dashboard
      query ||= params[:action].to_s + "?"

      policy = AdminOnly::DashboardPolicy.new(current_user, nil)
      unless policy.public_send(query)
        raise NotAuthorizedError, query: query, record: current_user, policy: policy
      end

    end
  end

end
