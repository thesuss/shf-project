#--------------------------
#
# @module Downloader
#
# @desc Responsibility: can download files, etc
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date  2022/04/08
#
#--------------------------

module Downloader

  protected

  def download_file(file_contents_str, export_filename = "shf-download-#{Time.now.strftime("%Y%m%dT%H%M")}",
                    success_msg: 'Success!', error_msg: 'Error: something went wrong with the export.')
    begin
      send_data(file_contents_str,
                filename: export_filename, type: "text/plain")
      helpers.flash_message(:notice, success_msg)

    rescue
      helpers.flash_message(:alert, error_msg)
      redirect_to(request.referer.present? ? :back : root_path)
    end
  end
end
