module AdminOnly

  module DesignGuideHelper

    DEFAULT_TEXT = ''
    DEFAULT_FILL_COLOR = '#ffffff'
    BUTTON_FILLER_TEXT = '.....'

    def color_ex(text=DEFAULT_TEXT, fill_color=DEFAULT_FILL_COLOR)
      color_ex_btn(fill_color) + tag.p(text, class: 'color-ex')
    end

    def color_ex_btn(fill_color=DEFAULT_FILL_COLOR, text=BUTTON_FILLER_TEXT)
      tag.button(text, class: 'color-ex', style: "color:#{fill_color}; background-color:#{fill_color}")
    end

  end

end
