# config/initializers/pdfkit.rb
PDFKit.configure do |config|
  # config.wkhtmltopdf = '/path/to/wkhtmltopdf'
  config.default_options = {
    page_size: 'A4',
    outline: true,
    print_media_type: true,
    enable_local_file_access: true
  }
  # config.root_url = "#{Rails.root.join('public', 'assets')}/"
  # Use only if your external hostname is unavailable on the server.
  config.root_url = 'http://0.0.0.0'
  # config.verbose = false
end
