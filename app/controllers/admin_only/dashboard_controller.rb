module AdminOnly

  class DashboardError < StandardError;
  end
  class DashboardMissingParameterError < DashboardError;
  end


  class DashboardController < AdminOnlyController

    before_action :set_data_gatherer


    def index

      @payments_search = Payment.ransack(params[:q])
      @payments = @payments_search.result

      render partial: 'payments', locals: { payments_search: @payments_search,
                                            payments: @payments } if request.xhr?

    end

    def payments
      @payments_search = Payment.ransack(params[:q])
      @payments = @payments_search.result

      render partial: 'payments', locals: { payments_search: @payments_search,
                                            payments: @payments } if request.xhr?

    end


    # WIP to change the timeframe for "recent" data.
    def update_timeframe

      #
      # This is just an example of using the handle_xhr_request method.
      # It doesn't actually do anything. (it's never called.)
      #
      handle_xhr_request do

        raise DashboardMissingParameterError, "Oh no! You're missing a parameter!" if params['data_gatherer'].blank? || params['data_gatherer']['timeframe'].blank?
        # could do other checks and raise any other errors here.
        #   Ex:
        #      @some_info = SomeActiveRecordModel.find_by(this_param: param1, that_param: param2)
        #      raise DashboardInfoNotFoundError, t('.not-found', info: param1)


        # @data_gatherer.timeframe = params['data_gatherer']['timeframe'].to_i

        # ... call methods to do interesting stuff...

        # return a Hash of info that will be sent back to the client
        { timeframe: params['data_gatherer']['timeframe'].to_i,
          data: 'super good data',
          other_data: 'suprising data'
        }
      end
    end


    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def dashboard_params
      params.require(:admin_only_dashboard).permit(:name_sv, :description_sv, :name_en, :description_en, :is_custom,
                                                   :data_gatherer, :data_gatherer[:timeframe])
    end


    # load the object that will gather all of the data to be displayed
    def set_data_gatherer
      @data_gatherer = AdminOnly::DataGatherer.new
    end

  end

end
