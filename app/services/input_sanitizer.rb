require 'sanitize'

class InputSanitizer

  def self.sanitize_url(url='')
    return '' if url.blank?

    Sanitize.fragment(url.gsub(/javascript/,''), Sanitize::Config::RESTRICTED)
  end

  def self.sanitize_html(html='')
    # "relaxed" setting accommodates all input that a user can create by
    # using the available menu options in our Ckeditor configuration.
    # This also strips out unwanted code the user might enter in "source" mode.
    return '' if html.blank?

    Sanitize.fragment(html, Sanitize::Config::RELAXED)
  end

  # see Loofah::Scrubbers::Whitewash / scrub!(:whitewash)
  def self.sanitize_string(unsafe_str = '')
    return '' if unsafe_str.blank?

    scrubbed_str = Loofah.fragment(unsafe_str).scrub!(:whitewash)
    scrubbed_str.text  # this strips out everything except just plain text
  end
end
