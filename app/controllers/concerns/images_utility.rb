module ImagesUtility

  private

  def send_as(context)
    context == 'internal' ? 'attachment' : 'inline'
  end

  def download_image(type, jpg_image, send_as)
    send_data(jpg_image, type: 'image/jpg', filename: "#{type}.jpg", disposition: send_as)
  end

  def show_image(image_html)
    render html: image_html.html_safe
  end

  def create_image_jpg(type, width, app_config, object)
    image_html = image_html(type, app_config, object,
                            render_as: :jpg, context: 'internal')
    kit = build_kit(image_html, "#{type.tr('_', '-')}.css", width)
    kit.to_jpg
  end

  def image_html(image_type, app_config, object, render_as, context=nil)
    object_sym = object.class.to_s.downcase.to_sym

    render_to_string(partial: image_type,
                     formats: [:html],
                     locals: { app_config: app_config,
                               render_as: render_as,
                               context: context,
                               object_sym => object})
  end

  def build_kit(image_html, image_css, width)
    kit = IMGKit.new(image_html, encoding: 'UTF-8', width: width, quality: 100)
    kit.stylesheets << Rails.root.join('app', 'assets', 'stylesheets',
                                       image_css)
    kit
  end


  def allow_iframe_request
    response.headers.delete('X-Frame-Options')
    # https://stackoverflow.com/questions/17542511/
    # cannot-display-my-rails-4-app-in-iframe-even-if-x-frame-options-is-allowall
  end
end
