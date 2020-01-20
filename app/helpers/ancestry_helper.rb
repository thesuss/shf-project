module AncestryHelper

  DEFAULT_LIST_TYPE = :ul
  DEFAULT_LIST_STYLE = ''
  DEFAULT_AS_LIST_OPTIONS = {
      list_type: DEFAULT_LIST_TYPE,
      list_style: DEFAULT_LIST_STYLE,
      ul_class: [],
      ul_class_top: [],
      ul_class_children: [],
      ul_id_method: lambda { |object| object.respond_to?(:id) ? "ul-db-id-#{object.id}" : "ul-oid-#{object.__id__}" },
      li_class: [],
      li_class_top: [],
      li_class_children: [],
      sort_by: [],
      li_id_method: lambda { |object| object.respond_to?(:id) ? "li-db-id-#{object.id}" : "li-oid-#{object.__id__}" }
  }

  BOOTSTRAP_UL_CLASS = 'list-group'
  BOOTSTRAP_LI_CLASS = 'list-group-item'


  # Based on https://github.com/stefankroes/ancestry/wiki/Nested-HTML-from-the-arrange-method
  #
  # If you have a need to render your ancestry tree of any depth you can use
  # the following helper to make it so.
  # The Helper takes some options, mostly for styling.
  #
  # Note: This helper should not care about filtering or children depth.
  #  That should be handled via the normal ancestry methods before arrange() is called.
  #
  # Secondary Note: This helper also assumes you are using the has_ancestry :cache_depth => true option.
  #  If you are not using this, remove the references in the helper to ancestry_depth.
  #
  #
  # Configuration options:
  #  :list_type # the type of list to render (ul or ol)
  #  :list_style # this is used for setting up some pre-formatted styles. Can be removed if not needed.
  #  :ul_class # applies given class(es) to all parent list groups (ul or ol)
  #  :ul_class_top # applies given class(es) to parent list groups (ul or ol) of depth = 0
  #  :ul_class_children # applies given class(es) to parent list group (ul or ol) of depth > 0
  #  :li_class # applies given class(es) to all list items (li)
  #  :li_class_top # applies given class(es) to list items (li) of depth = 0
  #  :li_class_children # applies given class(es) to list items (li) of depth > 0
  #
  # arranged as tree expects 3 arguments:
  #  - the hash from has_ancestry.arrange() method,
  #  - options,
  #  - and a render block
  #
  def arranged_tree_as_list(hash, options = {}, depth = 0, ul_id = '', &block)
    output = ''
    options = set_options(options)

    # sort the hash key based on sort_by options array if :sort_by is given
    unless options[:sort_by].empty?
      hash = Hash[hash.sort_by { |k, _v| options[:sort_by].map { |sort| k.send(sort) } }]
    end

    output << create_li_entries(hash, options, depth, block)
    output = create_ul(output, options, depth, ul_id) unless output.blank?

    output.html_safe
  end


  # Generate the list of CSS classes that should be applied to this ancestry item.
  # If it has children, the CSS class 'is-list' is added.
  # If it has no ancestors, then it is a "top level" list and so
  # the CSS class 'top-level-list' is added.
  #
  # Note that because this method calls :children? and :ancestors? queries will
  # happen. (These happen in the Ancestry gem: Ancestry::InstanceMethods#children
  # and Ancestry::InstanceMethods#ancestors?)
  # If these records are not already cached, this will cause N+1 queries.
  #
  # @return [Array<String>] - list of CSS classes for this list.
  #   If the list has no ancestors, it is a top level list and add the CSS class for that
  #   If the list has children, add the CSS class for that
  def list_entry_css_classes(list_entry)
    list_classes = []
    list_classes << (list_entry.children? ? 'is-list' : '')
    list_classes << (list_entry.ancestors? ? '' : 'top-level-list')

    list_classes
  end


  private


  def create_li_entries(hash = {}, options = {}, depth = 0, block)
    output = ''

    hash.each do |object, children|
      li_html_options = create_li_html_options(object, depth, options)

      if children.size > 0
        output << content_tag(:li, capture(object, &block) + arranged_tree_as_list(children, options, depth + 1, ul_id_for_object(object, options), &block).html_safe,
                              li_html_options)
      else
        output << content_tag(:li, capture(object, &block), li_html_options).html_safe
      end
    end
    output
  end


  def ul_id_for_object(object, options = {})
    options[:ul_id_method].call(object)
  end


  def create_li_html_options(object, depth = 0, options = {})
    li_classes = create_li_classes(depth, options)
    li_id_str = options[:li_id_method].call(object)
    { id: li_id_str, class: li_classes }
  end


  def create_li_classes(depth = 0, options = {})
    li_classes = options[:li_class]
    li_classes_to_add = (depth == 0 ? :li_class_top : :li_class_children)
    li_classes += options[li_classes_to_add]
    li_classes
  end


  def create_ul(inner_content, options = {}, depth = 0, ul_id = '')

    ul_classes_to_add = (depth == 0 ? :ul_class_top : :ul_class_children)
    ul_classes = options[:ul_class]
    ul_classes += options[ul_classes_to_add]

    ul_html_options = { class: ul_classes }
    ul_html_options = ul_html_options.merge({ id: ul_id, class: ul_classes }) unless ul_id.blank?

    content_tag(options[:list_type], inner_content.html_safe, ul_html_options)
  end


  def set_options(given_options = {})

    options = {}.merge(DEFAULT_AS_LIST_OPTIONS).merge(given_options)

    # set up any custom list styles you want to use here. An example is excluded
    # to render bootstrap style list groups. This is used to keep from recoding the same
    # options on different lists
    case options[:list_style]
      when :bootstrap_list_group
        options[:ul_class] += [BOOTSTRAP_UL_CLASS]
        options[:li_class] += [BOOTSTRAP_LI_CLASS]
    end

    options[:list_style] = '' # reset the options so that the case statement won't run again
    options
  end

end
