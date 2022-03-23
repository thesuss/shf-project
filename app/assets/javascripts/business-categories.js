var categories = {

  init: function() {
    'use strict';

    $('body').on('ajax:complete', '.delete-category', categories.removeCategory);

    $('body').on('ajax:complete', '.edit-category-button', categories.showEditRow);

    $('body').on('ajax:complete', '.edit-category-cancel-button', categories.showDisplayRow);

    $('body').on('ajax:complete', '.edit-category-form', categories.handleFormResults);

    $('body').on('ajax:complete', '.new-category-button', categories.showNewCategoryRow);

    $('body').on('click', '.new-category-cancel-button', categories.removeNewCategoryRow);
  },

  showEditRow: function(e, response) {
    if (Utility.httpErrorOccurred(response) === false) {
      var data = JSON.parse(response.responseText);

      // Receiving an edit row from server - replace display row with that
      var $displayRow = $('#category-display-row-' + data.business_category_id);

      $displayRow.replaceWith(data.edit_row);
      return false;
    }
  },

  showDisplayRow: function(e, response) {
    if (Utility.httpErrorOccurred(response) === false) {
      var data = JSON.parse(response.responseText);

      // Receiving display row from server - replace edit row with that
      var $editRow = $('#category-edit-row-' + data.business_category_id);

      $editRow.replaceWith(data.display_row);
      return false;
    }
  },

  showNewCategoryRow: function(e, response) {
    if (Utility.httpErrorOccurred(response) === false) {
      var data = JSON.parse(response.responseText);

      if (data.context === 'category') {
        // Receiving edit-category row (for new category) from server.
        $('#business_categories').append(data.new_row);
      }
      else {
        // Receiving edit-category row (for new subcategory) from server.
        // Insert this row immediately after the category row.

        $(this).closest('tr').after(data.new_row);
      }
    }
  },

  removeNewCategoryRow: function(e, response) {
    categories.removeThisRow(this);
    return false;
  },

  removeThisRow: function(this_one) {
    // Remove the parent table row within which this row exists
    $(this_one).closest('tr.category-edit-row').remove();
  },

  handleFormResults: function(e, response) {
    if (Utility.httpErrorOccurred(response) === false) {
      var data = JSON.parse(response.responseText);

      if (Utility.actionErrorOccurred(response, data) === false) {
        // Receiving a display row from server
        // If we find a matching edit row, replace that with the display row
        // If not, the display row is for a *new* category - append to table.

        var $editRow = $('#category-edit-row-' + data.business_category_id);

        if ($editRow.length === 1) {

          $editRow.replaceWith(data.display_row);

        } else {

          if (data.context === 'category') {

            $('#business_categories').append(data.display_row);

          } else {

            categories.addOrReplaceSubcategory(data);
          }

          // Remove the edit row where the category (or subcategory) was created
          categories.removeThisRow(this);
        }

      } else {
        $('#category-edit-errors').html(data.errors);
      }
    }
  },

  addOrReplaceSubcategory: function(data) {
    var $subcatRow = $('#subcategories-for-' + data.business_category_id);

    // Look for subcategory row - if found, replace; otherwise add

    if ($subcatRow.length === 1) {
      $subcatRow.replaceWith(data.display_row);
    } else {
      $('#category-display-row-' + data.business_category_id).after(data.display_row);
    }
  },

  removeCategory: function(e, response) {
    if (Utility.httpErrorOccurred(response) === false) {
      var $targetRow = $(e.target).closest('tr');
      var $targetTable = $targetRow.closest('table');
      var targetRowId = $targetRow.attr('id');
      var category_id = targetRowId.substring(21);
      var subcategories_row_id = '#subcategories-for-' + category_id;

      // Removed subcategories if present
      $(subcategories_row_id).remove();

      // remove row containing the 'delete-category' link
      $targetRow.fadeOut(800, function() {
        $(this).remove();
      });

      // If this is the last row in the containing table, and the table is
      // contained within a table row with id that begins with "subcategories-for-"
      // then delete that containing row (we have just deleted the last
      // subcategory for a category, so need to remove subcategories table)
      if ($targetTable.find('tbody>tr').length === 1) {
        $targetTable.closest('tr[id^="subcategories-for-"]').remove();
      }
    }
  }
}
