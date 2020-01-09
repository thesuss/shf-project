# Standardized icons and icon-related helpers to use in the app
#
#
module ShfIconsHelper

  FA_STYLE_DEFAULT = 'fas'
  FA_EDIT = 'edit'
  FA_USER_PROFILE = 'id-card'
  FA_USER_ACCOUNT = 'folder'
  FA_EXTERNAL_LINK = 'external-link-alt'


  # Create an entry for each method that you want to define and the icon name it should use
  #  A method will be created for each entry (see the class_eval below).
  METHODS_AND_ICONS = [
      { method_name_start: 'user_profile', icon: FA_USER_PROFILE },
      { method_name_start: 'user_account', icon: FA_USER_ACCOUNT },
      { method_name_start: 'edit', icon: FA_EDIT },
      { method_name_start: 'external_link', icon: FA_EXTERNAL_LINK },
  ]

  METHODS_AND_ICONS.each do |method_info|

    module_eval <<-end_method, __FILE__, __LINE__ + 1
      def #{method_info[:method_name_start]}_icon(fa_style = FA_STYLE_DEFAULT, text = nil, html_options = {})
        get_fa_icon(fa_style, '#{method_info[:icon]}', text, html_options)
      end
    end_method

  end


  private

  # Single point of connection (binding) to the FontAwesome icon method
  def get_fa_icon(fa_style, fa_icon, text = nil, html_options = {})
    icon(fa_style, fa_icon, text, html_options)
  end
end
