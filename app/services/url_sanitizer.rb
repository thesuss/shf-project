require 'sanitize'


class URLSanitizer

  def self.sanitize(url='')
    url ? Sanitize.fragment(url.gsub(/javascript/,''), Sanitize::Config::RESTRICTED) : ''
  end

end