module ExceptionsHelper

  DEFAULT_SCOPE = 'exception_handler.exceptions.show'


  def displayed_exception_title(exception, i18n_scope = DEFAULT_SCOPE)
    title_key ="#{ exception_prefix(exception)}_title"
    I18n.t(title_key, scope: i18n_scope)
  end


  def displayed_exception_message(exception, i18n_scope = DEFAULT_SCOPE)
    message_key ="#{ exception_prefix(exception)}_message"
    "#{ I18n.t(message_key, scope: i18n_scope) } #{ I18n.t('we_know', scope: i18n_scope) }"
  end


  def exception_image(exception)
    "#{exception_prefix(exception)}.jpg"
  end


  def exception_image_attribution_text(exception, i18n_scope = DEFAULT_SCOPE)
    attribution_key = "#{exception_prefix(exception)}_jpg_attribution"
    "#{ I18n.t(attribution_key, scope: i18n_scope) }"
  end


  def exception_prefix(exception)
    if error_4xx?(exception)
      '4xx'
    elsif error_5xx?(exception)
      '5xx'
    else
      '5xx'
    end
  end


  def error_4xx?(exception)
    status_starts_with?(exception, '4')
  end


  def error_5xx?(exception)
    status_starts_with?(exception, '5')
  end


  def status_starts_with?(exception, start)
    exception.status.to_s.first == start
  end
end
