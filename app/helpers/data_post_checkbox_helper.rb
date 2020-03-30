#--------------------------
#
# @module DataPostCheckboxHelper
#
# @desc Responsibility: Create the HTML for a checkbox with a data-remote method post action.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   12/25/19
#
#--------------------------

module DataPostCheckboxHelper

  # Create the HTML for a checkbox with a data-remote method post action.
  #
  # @see ActionView::Helpers::FormTagHelper#check_box_tag
  #
  # @return [String] - html_safe string that is a checkbox with a label for it
  def checkbox_with_post(name, value, checked, post_path, options = {})

    sanitized_class_name = name.to_s.delete(']').tr('^-a-zA-Z0-9:.', '-').dasherize
    class_and_post = { class: "checkbox.#{sanitized_class_name}",
                       data: { remote: true,
                               method: :post,
                               url: post_path } }

    check_box_tag(name, value, checked, class_and_post.merge(options)).html_safe
  end

end
