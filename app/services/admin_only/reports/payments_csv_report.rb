# frozen_string_literal: true

module AdminOnly
  module Reports
    #--------------------------
    #
    # @class PaymentsCsvReport
    #
    # @desc Responsibility: CSV report for all Payments
    #
    #
    # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
    # @date   1/25/21
    #
    #--------------------------

    class PaymentsCsvReport < CsvReport

      def self.csv_adapter
        ::Adapters::PaymentToCsvAdapter
      end

      # -----------------------------------------------------------------------------------------------

      def get_report_items(_args)
        ::Payment.includes(:user).includes(:company).all
      end

      def filename_start
        'betalningar'
      end
    end

  end
end
