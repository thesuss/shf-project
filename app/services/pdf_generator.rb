require 'pdfkit'

#--------------------------
#
# @class PdfGenerator
#
# @desc Responsibility: Generate PDF using PDFKit. This is a simple wrapper around PDFKit
#
# If PDFKit is failing, try turning off the :quiet option to see verbose results by passing
# in the option <code>quiet: false</code>
#   Ex: pdf(html_receipts, {quiet: false})
#
# If you get a "Broken Pipe" error, it may mean that the options passed to wkhtml2pdf are incorrect.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   4/7/22
#
#--------------------------

class PdfGenerator
  include Singleton

  TIMESTAMP_POSITION = 'header-right'

  def default_options
    @default_options ||=  { 'print-media-type': true }
  end


  def pdf(source_html, options = {})
    with_new_builder(source_html, options) { |pdfkit| pdfkit.to_pdf }
  end

  def pdf_file(source_html, filename, options = {})
    with_new_builder(source_html, options) { |pdfkit| pdfkit.to_file(filename) }
  end


  def with_new_builder(source_html, options = {})
    stylesheet_fn = options.delete(:stylesheet_fn)

    pdfkit = PDFKit.new(source_html, {timestamp_position => timestamp}.merge(default_options.merge(options)))
    pdfkit.stylesheets << stylesheet_fn if stylesheet_fn
    yield(pdfkit)
  end


  def timestamp_position
    TIMESTAMP_POSITION
  end

  # @return [String] the Time now in the given time zone, formatted as yyyy-mm-dd hh:mm:ss
  def timestamp(zone = 'CET')
    Time.use_zone(zone) { Time.zone.now.strftime("%F %T") }
  end
end
