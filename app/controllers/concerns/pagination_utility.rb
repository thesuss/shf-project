module PaginationUtility
  extend ActiveSupport::Concern

  # This constant is used to specify "all" items to be shown in a view that
  # uses the will_paginate gem for listing a collection.  That has to be a number.
  # This particular number is used when the user selects "All" in the
  # items-per-page selection.
  ALL_ITEMS = 10_000.freeze

  DEFAULT_ITEMS_SELECTION = 10.freeze # Default items-per-page setting

  def process_pagination_params(entity)

    # This method is used in controller actions involved in pagination of
    # collection tables (e.g., companies, member_applications).

    # It is passed a string that indicates the type of paginated collection,
    #  e.g. "company", "shf_application".

    # It returns:
    #  1) search params hash, for use with ransack gems "ransack" method,
    #  2) the user's last items-per-page selection (an integer or 'All'),
    #  3) the actual number of items-per-page to show in the table.

    # This method uses the session to store (and recover) search criteria
    # and per-page items selection.  These need to be persisted across action
    # invocations in order to accommodate the multiple ways in which a
    # typical controller "index" action might be called.

    # For instance, the companies_controller "index" action is called when:
    # 1) loading the index page,
    # 2) moving to another pagination page in the companies listing table (XHR),
    # 3) sorting on one of the table columns,
    # 4) executing a companies search from the index page, and,
    # 5) changing per-page items count in the pagination table on that page (XHR).

    entity_items_selection = (entity + '_items_selection').to_sym
    entity_search_criteria = (entity + '_search_criteria').to_sym

    if params[:items_count]  # << user has selected a per-page items count
      items_count = params[:items_count]
      items_selection = items_count == 'All' ? 'All' : items_count.to_i

      session[entity_items_selection] = items_selection

      search_criteria = JSON.parse(session[entity_search_criteria])

      search_params = search_criteria ?
        ActionController::Parameters.new(search_criteria) : nil

      # Reset params hash so that sort_link works correctly in the view
      # (the sort links are built using, as one input, the controller params)
      params[:q] = search_params
      params.delete(:items_count)

    else
      items_selection = session[entity_items_selection] ?
        session[entity_items_selection] : DEFAULT_ITEMS_SELECTION

      session[entity_search_criteria] = params[:q].to_json

      search_params = params[:q]
    end

    items_per_page = items_selection == 'All' ? ALL_ITEMS : items_selection

    [ search_params, items_selection, items_per_page ]
  end
end
