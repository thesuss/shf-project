# frozen_string_literal: true

module AdminOnly
  module Reports

    #--------------------------
    #
    # @class ShfApplicationsCsvReport
    #
    # @desc Responsibility: CSV report for all ShfApplications
    #
    #
    # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
    # @date   1/25/21
    #
    #--------------------------

    class ShfApplicationsCsvReport < CsvReport

      def self.csv_adapter
        ::Adapters::ShfApplicationToCsvAdapter
      end

      # -----------------------------------------------------------------------------------------------

      def get_report_items(_args)
        ::ShfApplication.includes(:user).all
      end

      def filename_start
        'Ansokningar'
      end
    end
  end
end
