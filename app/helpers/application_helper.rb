require 'meta_image_tags_helper'

module ApplicationHelper
  # TODO refactor these and methods to access them into a small module that can be used (e.g. also in the PaymentsHelper)
  CSS_CLASS_YES = 'yes' unless defined?(CSS_CLASS_YES)
  CSS_CLASS_NO = 'no' unless defined?(CSS_CLASS_NO)
  CSS_CLASS_MAYBE = 'maybe' unless defined?(CSS_CLASS_MAYBE)
  CSS_ADMIN_CLASS = 'is-admin' unless defined?(CSS_ADMIN_CLASS)
  CSS_CONTENT_TITLE_CLASS = 'entry-title'

  include MetaTagsHelper
  include MetaImageTagsHelper
  include ShfIconsHelper

  include ERB::Util # Required to test helpers that use h()

  # TODO standardize this method name:  should it end in '_css_class' to make it clear it is not related to Ruby classes?
  def flash_class(level)
    case level.to_sym
      when :notice then
        'success'
      when :alert then
        'danger'
      when :warn then
        'warning'
    end
  end


  def flash_message(type, text)
    flash[type] ||= []
    if flash[type].instance_of? String
      flash[type] = [flash[type]]
    end
    flash[type] << text
  end


  def render_flash_message(flash_value)
    if flash_value.instance_of? String
      flash_value
    else
      flash_value[0] = flash_value[0].html_safe
      safe_join(flash_value, '<br/>'.html_safe)
    end
  end


  def translate_and_join(error_list)
    error_list.map { |e| I18n.t(e) }.join(', ')
  end


  # ActiveRecord::Assocations::CollectionAssociation is a proxy and won't
  # always load info. see the class documentation for more info
  def association_empty?(assoc)
    assoc.reload unless assoc.nil? || assoc.loaded?
    assoc.nil? ? true : assoc.size == 0
  end


  def i18n_time_ago_in_words(past_time)
    "#{t('time_ago', amount_of_time: time_ago_in_words(past_time))}"
  end


  # call field_or_default with the default value = an empty String
  def field_or_none(label, value, tag: :p, tag_options: {}, separator: ': ',
                    label_class: default_field_label_css_class,
                    value_class: default_field_value_css_class)

    field_or_default(label, value, default: '', tag: tag, tag_options: tag_options, separator: separator,
                     label_class: label_class, value_class: value_class)
  end


  # Return a link to a FontAwesome icon.
  # If either the url or icon are nil, return nil.
  # Else use the FontAwesome :icon method to get the icon and create the link to the url
  # Assumes the :icon is a FontAwesome icon.  This does not check to see if it is or not.
  #
  # @param url [String] - ths is what :link_to will link to
  # @param icon [String] - the name of the FontAwesome icon, without any leading 'fa-'.  Ex: 'facebook', or 'youtube-square'
  # @return [String] - the HTML link to the icon, with the CSS classes 'fab' and 'fa-2x' applied and target '_blank'
  #
  def icon_link(url, icon, alt='', title='')
    title = alt if title.blank?
    alt = title if alt.blank?
    if url.blank? || icon.nil?
      nil
    else
      link_to icon('fab', icon, {class: 'fa-2x'}), url, {target: '_blank', alt: alt, title: title}
    end
  end


  # Return the HTML for a simple field with "Label: Value"
  # If value is blank, return the value of default (default value for default = '')
  # Surround it with the given content tag (default = :p if none provided)
  # and use the tag options (if any provided).
  # Default class to surround the label and separator is 'field-label'
  # Default class to surround the value is 'field-value'
  #
  # Separate the Label and Value with the separator string (default = ': ')
  #
  #  Ex:  field_or_none('Name', 'Bob Ross')
  #     will produce:  "<p><span class='field-label'>Name: </span><span class='field-value'>Bob Ross</span></p>"
  #
  #  Ex:  field_or_default('Name', '', default: '(no name provided)')
  #     will produce:  "(no name provided)"
  #
  #  Ex:  field_or_default('Name', '', default: content_tag( :h4, '(no name provided)', class: 'empty-warning') )
  #     will produce:  "<h4 class='empty-warning'>(no name provided)</h4>"
  #
  # Ex: field_or_none('Name', 'Bob Ross', tag: :h2, separator: ' = ')
  #     will produce:  "<h2><span class='field-label'>Name = </span><span class='field-value'>Bob Ross</span></h2>"
  #
  # Ex: field_or_none('Name', 'Bob Ross', tag_options: {id: 'bob-ross'}, value_class: 'special-value')
  #     will produce:  "<p id='bob-ross'><span class='field-label'>Name: </span><span class='special-value'>Bob Ross</span></p>"
  #
  def field_or_default(label, value, default: '', tag: :p, tag_options: {}, separator: ': ',
                       label_class: default_field_label_css_class,
                       value_class: default_field_value_css_class)
    if value.blank?
      default
    else
      content_tag(tag, tag_options) do
        concat content_tag(:span, "#{label}#{separator}", class: label_class)
        concat content_tag(:span, value, class: value_class)
      end
    end
  end

  def default_field_value_css_class
    'field-value'
  end

  def default_field_label_css_class
    'field-label'
  end

  # Construct a string that can be used by CSS to style things in a particular view.
  # TODO standardize this method name:  should it end in '_css_class' to make it clear it is not related to Ruby classes?
  #
  def item_view_class(active_record_item, action_name)
    "#{action_name} #{active_record_item.class.name.downcase} #{unique_css_id(active_record_item)}"
  end


  # Construct a CSS identifier unique to this instance of an ActiveRecord
  # This is helpful so that this item can be uniquely identified on a page
  #  so that it can be (perhaps uniquely) styled.
  #
  # If the item does not have an ID, then we will have to assign on based on the
  # current UTC time in seconds, which will be of little use for CSS styling, but
  # there are no pretty alternatives.
  def unique_css_id(active_record_item)
    unique_id = if active_record_item.respond_to?(:id) && active_record_item.id
                  active_record_item.id.to_s
                else
                  "no-id--#{Time.now.utc.to_i}"
                end

    "#{active_record_item.class.name.downcase}-#{unique_id}"
  end

  # Returns a string of option tags for a 'select' element.
  # The select element allows the user to select the number of items to
  # appear on each pagination page.
  # The 'count' argument is the currently-select items count.

  ITEMS_COUNT = [ ['10', 10], ['25', 25], ['50', 50], ['All', 'All'] ].freeze

  def paginate_count_options(count=10)
    options_for_select(ITEMS_COUNT, count)
  end

  def model_errors_helper(model_instance)
    html = ''
    errs = model_instance.errors.count

    if errs > 0
      html = "<div class='alert alert-danger'>"
      html << content_tag(:h4, "#{t('model_errors', count: errs)}:", class: 'alert-heading')

      model_instance.errors.full_messages.each do |msg|
        html << content_tag(:p, msg)
      end
    html << "</div>"
    end

    html.empty? ? nil : html + tag(:br)
  end

  def boolean_radio_buttons_collection(text_vals = { true: 'Yes', false: 'No' })
    # Returns generic collection for radio buttons for a boolean field,
    # suitable for use in radio button selection fields.  Text values are
    # translated. Can pass in preferred strings for "true" and "false" text values.
    [ [true, t(text_vals[:true])], [false, t(text_vals[:false])] ]
  end


  # return a span tag with class yes || no and text = t('yes')||t('no') depending on the boolean value
  def yes_no_span(boolean_value)
    span_with_yes_no_css_class((boolean_value ? t('yes'): t('no')), boolean_value)
  end


  # Return a span tag with text = text, and class = the yes or no CSS class
  # depending on the boolean_value
  # This ensures that we are always using the same CSS classes for styling
  # yes and no
  #
  # Ex:
  #   span_with_yes_no_css_class('surround this text', true)
  #    => "<span class: 'yes'>surround this text</span>"
  #
  #   span_with_yes_no_css_class('surround this text', false)
  #    => "<span class: 'no'>surround this text</span>"
  #
  def span_with_yes_no_css_class(text, boolean_value)
    content_tag(:span, text, class: (boolean_value ? yes_css_class : no_css_class))
  end


  # Create and return a span tag for use as a tooltip with a FontAwesome icon.
  # Sets the text to appear in the tooltip, sets data-toggle: 'tooltip',
  # and by default uses the 'fas' 'fa-info-circle' icon.
  # You can optionally give the name of the icon to be used ("fa-" will be prepended),
  # and optionally the name of the FontAwesome group.
  #
  # Example: fas_tooltip("This is the text when the user hovers over the icon")
  #   will return
  #    '<span class="i fas fa-info-circle"
  #        title=""
  #        data-original-title="This is the text when the user hovers over the icon">
  #        data-toggle="tooltip"
  #     </span>'
  #
  # Example: fas_tooltip("tooltip text", fa_icon: 'calendar-alt')
  #   will return
  #    '<span class="i fas fa-calendar-alt"
  #        title=""
  #        data-original-title="tooltip text">
  #        data-toggle="tooltip"
  #     </span>'
  #
  # Example: fas_tooltip(I18n.t('share_on_facebook'), fa_icon_group: 'fab', fa_icon: 'facebook')
  #   will return
  #    '<span class="i fab fa-facebook"
  #        title=""
  #        data-original-title="Share on Facebook">
  #        data-toggle="tooltip"
  #     </span>'
  #
  #
  # @param title [String] - text the will appear in the tooltip
  # @param fa_icon_group [String] - one of the main FontAwesome groups. Default is 'fas'
  # @param fa_icon [String] - the FontAwesome icon to use, _without_ the leading 'fa'. Default is 'info-circle'
  #   The leading 'fa-' is added automatically
  #
  # @return [String] - the html safe string for the entire <span>
  #
  def fas_tooltip(title, fa_icon_group: 'fas', fa_icon: 'info-circle')
    content_tag :span do
      concat icon(fa_icon_group, fa_icon, '', data: {toggle: 'tooltip', original_title: title})
    end
  end


  def full_page_title(page_title: '',
                      site_name: '')

    not_blank_title = page_title.blank? ? AdminOnly::AppConfiguration.config_to_use.site_meta_title : page_title
    not_blank_sitename = site_name.blank? ? AdminOnly::AppConfiguration.config_to_use.site_name : site_name
    "#{not_blank_title} | #{not_blank_sitename}"
  end


  PRESENCE_VALIDATORS = [
      Paperclip::Validators::AttachmentPresenceValidator,
      ActiveRecord::Validations::PresenceValidator
  ]


  def presence_required?(model_instance, attribute)
    presence_validators = model_instance.class.validators.select{|v| is_a_presence_validator?(v)}
    presence_validators.any?{|pv| pv.attributes.include?(attribute.to_sym)}
  end


  def is_a_presence_validator?(validator)
    PRESENCE_VALIDATORS.include?(validator.class)
  end


  # If the user is an admin, append the appropriate CSS class
  #
  # @param current_classes [Array[String]] - list of CSS classes
  # @return [Array] - a list of the current_classes with the admin class appended if needed
  def with_admin_css_class_if_needed(user, current_classes = [])
    user&.admin? ? (current_classes << admin_css_class) : current_classes
  end


  # public method for accessing the CSS class for displaying the 'is admin' indicator
  def admin_css_class
    CSS_ADMIN_CLASS
  end


  # public method for accessing the CSS class for displaying a 'yes' indicator
  def yes_css_class
    CSS_CLASS_YES
  end

  # public method for accessing the CSS class for displaying a 'no' indicator
  def no_css_class
    CSS_CLASS_NO
  end


  # public method for accessing the CSS class for displaying a 'maybe' indicator
  def maybe_css_class
    CSS_CLASS_MAYBE
  end

  # public method for accessing the CSS class for the main title of a page
  def content_title_css_class
    CSS_CONTENT_TITLE_CLASS
  end

  # public method to render the main title of a page
  def content_title(title = '', user: nil, id: nil, classes: [])
    tag.h1 title&.html_safe,
           class: classes + with_admin_css_class_if_needed(user, [content_title_css_class]),
           id: id
  end

  def nav_menu_login_title(user)
    t('hello', name: user.first_name)
  end


  def user_name_for_display(user)
    return '' unless user

    user_name = user.full_name
    user_name = user.email if user_name.blank?
    h(user_name)
  end

  def show_if_user_is_admin(user, text_if_they_are_admin)
    user.admin? ? tag.span("#{text_if_they_are_admin}", class: 'small') : ''
  end

  def edit_account_link(user, url: admin_only_edit_user_account_path(user), text: user_account_icon, title: '', show_if: true)
    show_if ? link_to(text, url, class: ['shf-icon', 'edit-user-account-icon'], title: title) : ''
  end

  def edit_profile_link(user, url: admin_only_user_profile_edit_path(user), text: user_profile_icon, title: '', show_if: true)
    show_if ? link_to(text, url, class: ['shf-icon', 'edit-user-profile-icon'], title: title) : ''
  end


  # TODO is this used?  Should it be used?
  # @return [String] HTML safe string for a FontAwesome checkbox with the text = displayed_text
  #   Use a square checkbox by default. if use_circle: true, use a circular one
  def fa_checkbox(is_checked = false, displayed_text = '',
                              use_circle: false, html_options: {})
    append_sq_str = use_circle ? '' : '_sq'
    icon_method = is_checked ? 'complete_check' : 'not_complete_check'

    checkbox_icon_method = "#{icon_method}#{append_sq_str}_icon".to_sym
    self.send(checkbox_icon_method, text: displayed_text, html_options: html_options)
  end

  # @param [String] title - title for the entire legend
  # @param [Array[String]] title_classes - list of CSS classes for the title. These will be applied
  #   with a span tag that surrounds the title.
  # @param [Array[String]] legend_classes - list of CSS classes for the entire legend.
  #   These will be applied to the div tag that surrounds the entire legend; they are added to
  #   the default CSS classes for the legend.
  # @param [Array[String]] entries - list of legend entries to display. A legend entry can be
  #   created with the ApplicationHelper#legend_entry method.
  #
  # @return [String] - HTML for a legend
  def legend(title: '', title_classes: [], legend_classes: [],
             entries: [])
    return '' if title.empty? && entries.empty?

    legend_default_classes = ['legend']
    legend_entries = entries.map{|entry| legend_entry(entry[:title], entry[:css_classes]) }

    tag.div class: (legend_classes | legend_default_classes) do
      concat(tag.span title.html_safe, class: title_classes)
      legend_entries.each{|entry| concat entry}.join(' ')
    end
  end

  # @return [String] - HTML formatted to display a legend entry: a span with the given
  #   CSS classes AND the default CSS classes for a legend entry
  # @param [String] display_string - the string to display for this entry
  # @param [Array[String]] css_classes - a list of CSS classes to apply to the display_string.
  #   These are added (AND) to the default CSS classes for display strings.
  def legend_entry(display_string = '', css_classes = [])
    return '' if display_string.empty?
    css_classes = [] if css_classes.nil?
    legend_classes = ['legend-item']
    tag.span display_string.html_safe, class: (legend_classes | css_classes)
  end


  # Durations

  # @return [String] - I18n string showing the years, months, days, hours, minutes, seconds
  #   Note that the DateHelper :distance_of_time_in_words will
  #   round and approximate times, so you might end up with "about...".
  #   We want the exact duration with no rounding.
  def duration_i18n(duration, options = {})
    options = {
      scope: :'datetime.distance_in_words'
    }.merge!(options)

    translated_parts = []
    I18n.with_options locale: options[:locale], scope: options[:scope] do |locale|
      translated_parts << locale.t(:x_years, count: duration.parts[:years]) if duration.parts.key?(:years)
      translated_parts << locale.t(:x_months, count: duration.parts[:months]) if duration.parts.key?(:months)
      translated_parts << locale.t(:x_weeks, count: duration.parts[:weeks]) if duration.parts.key?(:weeks)
      translated_parts << locale.t(:x_days, count: duration.parts[:days]) if duration.parts.key?(:days)
      translated_parts << locale.t(:x_hours, count: duration.parts[:hours]) if duration.parts.key?(:hours)
      translated_parts << locale.t(:x_minutes, count: duration.parts[:minutes]) if duration.parts.key?(:minutes)
      translated_parts << locale.t(:x_seconds, count: duration.parts[:seconds]) if duration.parts.key?(:seconds)
    end

    translated_parts.to_sentence
  end

  # @return [String] email address for the SHF membership chairperson
  def membership_chair_email
    ENV['SHF_MEMBERSHIP_EMAIL']
  end
end
