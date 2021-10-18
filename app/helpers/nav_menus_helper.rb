# Helpers for construction nav (navigation) menus
#
module NavMenusHelper

  NAV_LINK_CLASS = 'nav-link'
  DEFAULT_NAV_LINK_CLASSES = [NAV_LINK_CLASS]
  DEFAULT_LINK_OPTIONS = { class: DEFAULT_NAV_LINK_CLASSES }

  LI_DROPDOWN_CLASS = 'dropdown'
  DEFAULT_LI_DROPDOWN_CLASSES = [LI_DROPDOWN_CLASS]
  NAV_LINK_DROPDOWN_CLASS = 'dropdown-toggle'
  DEFAULT_DROPDOWN_LINK_CLASSES = [NAV_LINK_DROPDOWN_CLASS] + DEFAULT_NAV_LINK_CLASSES

  DEFAULT_DROPDOWN_LINK_OPTIONS = { "aria-expanded" => "false", "aria-haspopup" => "true", "data-toggle" => "dropdown"}


  # ============================================================================================

  # You can pass in a block and the HTML generated will appear 'nested' within the li element
  #
  # Ex (HAML):
  #   = nav_menu_dropdown_li(text: 'Top Dropdown Menu Item', link: '#top-item') do
  #     %ul.dropdown-menu
  #      = nav_menu_item_li(text: 'Sub Item 1', link: '#sub-1')
  #      = nav_menu_item_li(text: 'Sub Item 2', link: '#sub-2')
  #
  #   will generate:
  #     <li class="dropdown"><a aria-expanded="false" aria-haspopup="true" data-toggle="dropdown" class="dropdown-toggle nav-link" href="#top-item">Top Dropdown Menu Item</a>
  #       <ul class="dropdown-menu">
  #         <li class=""><a class="nav-link" href="#sub-1">Sub Item 1</a></li>
  #         <li class=""><a class="nav-link" href="#sub-2">Sub Item 1</a></li>
  #       </ul>
  #     </li>
  #
  def nav_menu_dropdown_li(text: '', link: '#', link_classes: [], link_options: {}, li_classes: [])
    options = create_link_options(link_classes: link_classes,
                                  link_options: link_options,
                                  default_classes: DEFAULT_DROPDOWN_LINK_CLASSES,
                                  default_link_options: DEFAULT_DROPDOWN_LINK_OPTIONS)

    tag.li(class: (DEFAULT_LI_DROPDOWN_CLASSES | li_classes)) do
      concat(link_to(text, link, options))

      yield if block_given?
    end
  end


  def nav_menu_item_li(text: '', link: '#', link_classes: [], link_options: {}, li_classes: [])
    options = create_link_options(link_classes: link_classes,
                                  link_options: link_options,
                                  default_classes: DEFAULT_NAV_LINK_CLASSES,
                                  default_link_options: DEFAULT_LINK_OPTIONS)
    tag.li(class: li_classes) do
      link_to(text, link, options)
    end
  end


  # @return [Hash] - the options, including :classes as a key, including items from link_classes
  def create_link_options(link_classes: [], link_options: {},
                          default_classes: [], default_link_options: {})
    options = default_link_options.merge(link_options)

    # build the list of link classes from the given link_classes and defaults
    link_classes_with_defaults = link_classes | default_classes
    link_classes_with_defaults = link_classes_with_defaults | options[:class] if options[:class]

    options.delete(:class)
    options[:class] = link_classes_with_defaults
    options
  end


end
