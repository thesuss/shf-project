class AdminController < AdminOnlyController
  include Downloader

  # FIXME - this is really an exporter!

  def export_ansokan_csv
    download_csv(AdminOnly::Reports::ShfApplicationsCsvReport.new, t('.success'), t('.error'))
  end


  def export_payments_csv
    download_csv(AdminOnly::Reports::PaymentsCsvReport.new, t('.success'), t('.error'))
  end


  def export_payments_covering_year_csv
    download_csv(AdminOnly::Reports::PaymentsCoveringYearCsvReport.new(params[:year]),
                 t('.success'), t('.error'))
  end

  def download_csv(csv_report, success_message, error_message)
    download_file(csv_report.to_csv, csv_report.csv_filename,
                  success_msg: success_message, error_msg: error_message)
  end

end
