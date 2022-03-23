Feature: Admin creates, views,  edits, or deletes a Master Checklist item

  A "Master Checklist" is a basic list that is ordered, and items can be nested
  (lists can contain other lists).
  It is the basis/template for each User Checklist.
  Only an admin can create, edit, or delete them.

  As an admin
  So that I can set up a master list of things that users should do
  And so I can later track the progress of users with the list
  I need to be able to create, view, edit, or delete User  Master Checklists.
  (CRUD: Create, Read (view), Edit (update), Delete)


  Background:
    Given the date is set to "2020-01-01"
    And the Membership Ethical Guidelines Master Checklist exists
      # This creates a short list of ethical guideline master checklists AND marks them as 'in use'


    Given the following users exist:
      | email        | admin | member |
      | admin@shf.se | true  |        |


    Given the following Master Checklist exist:
      | name                         | displayed_text               | description                                                | list position | parent name           | is in use |
      | Submit yer app               | Submit Your Application      | top level list with no parent                              | 0             | Membership            | false     |
      | Provide co nummer            | Provide Your Company Number  | provide the Org Nm. for at least 1 company                 | 1             | Submit yer app        | false     |
      | Document Business Categories | Document Business Categories | Provide documents for your business categories (skills)    | 2             | Submit yer app        | false     |
      | Some other list (SOL)        | some list                    | some other top level list                                  |               |                       | true      |
      | SOL entry 0                  | sol 0                        | entry 0 in Some other list (SOL); not a list (no children) | 0             | Some other list (SOL) | true      |
      | SOL entry 2                  | sol 2                        | entry 2 in Some other list (SOL); not a list (no children) | 2             | Some other list (SOL) | true      |
      | SOL entry 1                  | sol 1                        | entry 1 in Some other list (SOL); 1 child                  | 1             | Some other list (SOL) | true      |
      | SOL subentry 1.1             | sol 1 - subitem 1            | subentry 1.1                                               | 0             | SOL entry 1           | true      |


    Given I am logged in as "admin@shf.se"



  # ----------------------
  # VIEW (read) Master checklists
  # UX: Can edit/view all items in the list (linked, buttons, or icons or something)

  Scenario: See all checklists on the manage checklists page
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title") in the h1 title
    And I should see 14 Master Checklist listed

    # Verify that all entries are shown - these are the _names_ (not the displayed text)

    # This is the short list of Membership guidelines that is created:
    And I should see the item named "Medlemsåtagande" in the list of Master Checklist items
    And I should see the item named "Section 1" in the list of Master Checklist items as child 0 of "Medlemsåtagande"
    And I should see the item named "Guideline 1.1" in the list of Master Checklist items as child 0 of "Section 1"
    And I should see the item named "Guideline 1.2" in the list of Master Checklist items as child 1 of "Section 1"
    And I should see the item named "Section 2" in the list of Master Checklist items as child 1 of "Medlemsåtagande"
    And I should see the item named "Guideline 2.1" in the list of Master Checklist items as child 0 of "Section 2"

    And I should see the item named "Some other list (SOL)" in the list of Master Checklist items
    And I should see the item named "SOL entry 0" in the list of Master Checklist items as child 0 of "Some other list (SOL)"
    And I should see the item named "SOL entry 1" in the list of Master Checklist items as child 1 of "Some other list (SOL)"
    And I should see the item named "SOL subentry 1.1" in the list of Master Checklist items as child 0 of "SOL entry 1"
    And I should see the item named "SOL entry 2" in the list of Master Checklist items as child 2 of "Some other list (SOL)"

    # These are not in use:
    And I should see "Submit yer app" in the "archived-items" table
    And I should see "Provide co nummer" in the "archived-items" table
    And I should see "Document Business Categories" in the "archived-items" table


  Scenario: Clicking on an entry name will go to the view for it
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title") in the h1 title
    When I click on "SOL entry 0"
    Then I should see "SOL entry 0" in the h1 title


  Scenario: Clicking on the displayed text for an entry will go to the view for it
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title") in the h1 title
    When I click on "some list" link
    Then I should see "Some other list (SOL)" in the h1 title


  Scenario: The parent list for an entry is shown and clicking on it goes to the view for the parent
    Given I am on the page for Master Checklist item named "SOL entry 0"
    Then I should see "SOL entry 0" in the h1 title
    And I should see "Some other list (SOL)"
    When I click on "Some other list (SOL)"
    Then I should see "Some other list (SOL)" in the h1 title


  # -----------------
  # CREATE Master checklists

  Scenario: Create a new item and do not pick a parent list. It should show on the list of checklists on the manage checklists page at the top level
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title") in the h1 title
    When I click on the t("admin_only.master_checklists.index.new_item") link
    Then I should see t("admin_only.master_checklists.new.title")
    When I fill in t("admin_only.master_checklists.form.name") with "A new checklist"
    And I fill in t("admin_only.master_checklists.form.displayed_text") with "Shiny New Checklist"
    And I fill in t("admin_only.master_checklists.form.description") with "description for this new checklist"
    And I click on the t("submit") button
    Then I should see t("admin_only.master_checklists.create.success", name: "A new checklist")
    And I should see "A new checklist" in the h1 title

    When I am on the "manage checklist masters" page
    Then I should see the item named "A new checklist" in the list of Master Checklist items


  Scenario: Create an item in a list and specify the position. Position should be right and others in the list should be adjusted.
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title") in the h1 title
    When I click on the t("admin_only.master_checklists.index.new_item") link
    Then I should see t("admin_only.master_checklists.new.title")
    When I fill in t("admin_only.master_checklists.form.name") with "Inserted as 2nd item"
    And I fill in t("admin_only.master_checklists.form.displayed_text") with "Some Other List - another one"
    And I fill in t("admin_only.master_checklists.form.description") with "description for this new checklist"
    And I select "Some other list (SOL)" as the parent list
    # TODO I can't figure out why I have to use the #id of the input field below to have Capybara find it
    And I fill in "master-list-position" with "2"
    And I click on the t("submit") button

    Then I should see t("admin_only.master_checklists.create.success", name: "Inserted as 2nd item")
    And I should see "Inserted as 2nd item" in the h1 title

    When I am on the "manage checklist masters" page
    Then I should see the item named "Inserted as 2nd item" in the list of Master Checklist items as child 1 of "Some other list (SOL)"
    And I should see the item named "SOL entry 0" in the list of Master Checklist items as child 0 of "Some other list (SOL)"
    And I should see the item named "SOL entry 1" in the list of Master Checklist items as child 2 of "Some other list (SOL)"
    And I should see the item named "SOL entry 2" in the list of Master Checklist items as child 3 of "Some other list (SOL)"


  Scenario: Create an item in a list and do not specify the position. It should be put at the end
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title") in the h1 title
    When I click on the t("admin_only.master_checklists.index.new_item") link
    Then I should see t("admin_only.master_checklists.new.title")
    When I fill in t("admin_only.master_checklists.new.name") with "Another SOL item"
    And I fill in t("admin_only.master_checklists.new.displayed_text") with "Some Other List - another one"
    And I fill in t("admin_only.master_checklists.new.description") with "description for this new checklist"
    And I select "Some other list (SOL)" as the parent list

    And I fill in "master-list-position" with ""
    And I click on the t("submit") button

    Then I should see t("admin_only.master_checklists.create.success", name: "Another SOL item")
    And I should see "Another SOL item" in the h1 title

    When I am on the "manage checklist masters" page
    When I am on the "manage checklist masters" page
    Then I should see the item named "Another SOL item" in the list of Master Checklist items as child 3 of "Some other list (SOL)"


  Scenario: Create an item in a list and specify the position that is the same as an item now marked as 'no longer in use'. Position should be right and others in the list should be adjusted.
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title") in the h1 title
    When I click on the t("admin_only.master_checklists.index.new_item") link
    Then I should see t("admin_only.master_checklists.new.title")
    When I fill in t("admin_only.master_checklists.form.name") with "Inserted as 2nd item"
    And I fill in t("admin_only.master_checklists.form.displayed_text") with "Some Other List - another one"
    And I fill in t("admin_only.master_checklists.form.description") with "description for this new checklist"
    And I select "Some other list (SOL)" as the parent list
    # TODO I can't figure out why I have to use the #id of the input field below to have Capybara find it
    And I fill in "master-list-position" with "2"
    And I click on the t("submit") button

    Then I should see t("admin_only.master_checklists.create.success", name: "Inserted as 2nd item")
    And I should see "Inserted as 2nd item" in the h1 title

    When I am on the "manage checklist masters" page
    Then I should see the item named "Inserted as 2nd item" in the list of Master Checklist items as child 1 of "Some other list (SOL)"
    And I should see the item named "SOL entry 0" in the list of Master Checklist items as child 0 of "Some other list (SOL)"
    And I should see the item named "SOL entry 1" in the list of Master Checklist items as child 2 of "Some other list (SOL)"
    And I should see the item named "SOL entry 2" in the list of Master Checklist items as child 3 of "Some other list (SOL)"


  # ---------------
  # READ (View) Master checklists

  Scenario: View a Master Checklist - this info is always shown for all master checklists
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title") in the h1 title
    When I click on "SOL entry 1"
    Then I should see "SOL entry 1" in the h1 title

    # Status
    And I should see t("admin_only.master_checklists.status_numbers_row.status")
    And I should see t("admin_only.master_checklists.completed_numbers_span.completed")
    And I should see t("admin_only.master_checklists.completed_numbers_span.not_completed")

    # Parent
    And I should see t("admin_only.master_checklists.show.parent_list")

    # Position in list
    And I should see t("admin_only.master_checklists.show.list_position")

    # Info Displayed to users
    And I should see t("admin_only.master_checklists.show.displayed_text")
    And I should see "sol 1"
    And I should see "entry 1 in Some other list (SOL); 1 child"

    # Admin notes
    And I should see t("admin_only.master_checklists.show.notes")

    # ------------
    # Buttons at the bottom:
    And I should see t("admin_only.master_checklists.action_buttons.all_list_items")


  Scenario: View a top-level Master Checklist
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title") in the h1 title
    When I click on "Some other list (SOL)"
    Then I should see "Some other list (SOL)" in the h1 title
    And I should see t("admin_only.master_checklists.show.displayed_text")

    # checklist type - only displayed for a top level list
    And I should see t("admin_only.master_checklists.show.subtitle_list_type_start")
    And I should see "Medlemsåtagande"
    And I should see t("admin_only.master_checklists.show.subtitle_list_type_end")

    # Parent: This is a top level list
    And I should see t("admin_only.master_checklists.show.parent_list")
    And I should see t("admin_only.master_checklists.show.top_level_list")

    # Info Displayed to users
    And I should see t("admin_only.master_checklists.show.displayed_text")
    And I should see "some list"
    And I should see "some other top level list"

    #children
    And I should see t("admin_only.master_checklists.show.child_items")
    And I should see "SOL entry 0"
    And I should see "SOL entry 1"
    And I should see "SOL entry 2"

    # button: Add a new item to the list
    And I should see t("admin_only.master_checklists.show.new_child_in_list")


  Scenario: View a Master Checklist that has a parent and children
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title") in the h1 title
    When I click on "SOL entry 1"
    Then I should see "SOL entry 1" in the h1 title

    # Parent
    And I should see t("admin_only.master_checklists.show.parent_list")

    # Info Displayed to users
    And I should see t("admin_only.master_checklists.show.displayed_text")
    And I should see "sol 1"
    And I should see "entry 1 in Some other list (SOL); 1 child"

    #children
    And I should see t("admin_only.master_checklists.show.child_items")
    And I should see "SOL subentry 1.1"

    # button: Add a new item to the list (Show Add New child item button if Master Checklist can add a child)
    And I should see t("admin_only.master_checklists.show.new_child_in_list")


  Scenario: Master Checklist is in use: show note and Set to Not in Use button (but not delete button)
    Given I am on the "manage checklist masters" page
    When I click on "Section 1"
    Then I should see "Section 1" in the h1 title
    And I should see t("admin_only.master_checklists.no_more_major_changes_note_if_needed.no_more_changes_allowed")
    And I should see t("admin_only.master_checklists.no_more_major_changes_note_if_needed.can_clone")

    And I should see t("admin_only.master_checklists.action_buttons.mark_no_longer_used_clone")
    And I should see t("admin_only.master_checklists.delete_button_if_applicable.set_to_not_used")
    And I should not see t("admin_only.master_checklists.delete_button_if_applicable.delete", name: "Section 1")


  Scenario: Show delete button if the list is not in use and all children can be deleted
    Given I am on the "manage checklist masters" page
    When I click on "Submit yer app"
    Then I should see "Submit yer app" in the h1 title
    And I should see t("admin_only.master_checklists.delete_button_if_applicable.delete", name: "Submit yer app")
    And I should not see t("admin_only.master_checklists.delete_button_if_applicable.set_to_not_used")



  # ---------------
  # UPDATE (Edit) Master checklists

  Scenario: Rename a checklist that is a sublist and a parent
    Given I am on the "manage checklist masters" page
    When I click on "SOL entry 1"
    Then I should see "SOL entry 1" in the h1 title
    When I click on t("admin_only.master_checklists.action_buttons.edit_list_item")
    Then I should see "SOL entry 1" in the h1 title
    When I fill in t("admin_only.master_checklists.form.name") with "new some list 1 name"
    And I click on the t("submit") button
    Then I should see t("admin_only.master_checklists.update.success", name: "new some list 1 name")

    # Should see the rename in the list of all Master Checklists
    When I am on the "manage checklist masters" page
    Then I should see "new some list 1 name"
    And I should not see "SOL entry 1"

    # View the parent list(s); should see the rename
    When I click on "Some other list (SOL)"
    Then I should see "new some list 1 name"
    And I should not see "SOL entry 1"

    # View the child list(s); should see the rename
    When I am on the "manage checklist masters" page
    And I click on "SOL subentry 1.1"
    Then I should see "new some list 1 name"
    And I should not see "SOL entry 1"


  Scenario: Change the status to 'no longer used'
    Given I am on the "manage checklist masters" page
    When I click on "Section 1"
    Then I should see "Section 1" in the h1 title
    When I click on t("admin_only.master_checklists.delete_button_if_applicable.set_to_not_used")
    Then I should see t("admin_only.master_checklists.set_to_no_longer_used.success", name: "Section 1")
    And I should see t("admin_only.master_checklists.show.is_no_longer_used")

    # Children are listed as no longer used:
    And I should see "Guideline 1.1" in the "archived-items" table
    And I should see "Guideline 1.2" in the "archived-items" table

    # Action buttons:
    And I should not see t("admin_only.master_checklists.action_buttons.mark_no_longer_used_clone")
    And I should not see t("admin_only.master_checklists.delete_button_if_applicable.set_to_not_used")
    And I should not see t("admin_only.master_checklists.delete_button_if_applicable.delete", name: "Section 1")

    When I am on the "manage checklist masters" page
    Then I should see "Section 1" in the "archived-items" table
    And I should see "Guideline 1.1" in the "archived-items" table
    And I should see "Guideline 1.2" in the "archived-items" table

    # Each child is shown correctly:
    And I click on first "Guideline 1.1" link
    Then I should see "Guideline 1.1" in the h1 title
    And I should see t("admin_only.master_checklists.show.is_no_longer_used")
    And I should not see t("admin_only.master_checklists.action_buttons.mark_no_longer_used_clone")
    And I should not see t("admin_only.master_checklists.delete_button_if_applicable.set_to_not_used")
    And I should not see t("admin_only.master_checklists.delete_button_if_applicable.delete", name: "Guideline 1.1")

    When I am on the "manage checklist masters" page
    And I click on first "Guideline 1.2" link
    Then I should see "Guideline 1.2" in the h1 title
    And I should see t("admin_only.master_checklists.show.is_no_longer_used")
    And I should not see t("admin_only.master_checklists.action_buttons.mark_no_longer_used_clone")
    And I should not see t("admin_only.master_checklists.delete_button_if_applicable.set_to_not_used")
    And I should not see t("admin_only.master_checklists.delete_button_if_applicable.delete", name: "Guideline 1.2")


  # ----------------
  # Reordering Master checklists

  Scenario: Change the list position to the first item in the list. All other items are moved down (positions incremented)
    Given I am on the "manage checklist masters" page
    When I click on "SOL entry 2"
    Then I should see "SOL entry 2" in the h1 title
    When I click on t("admin_only.master_checklists.action_buttons.edit_list_item")
    And I fill in "master-list-position" with "1"
    And I click on the t("submit") button
    Then I should see t("admin_only.master_checklists.update.success", name: "SOL entry 2")

    When I am on the "manage checklist masters" page
    Then I should see the item named "SOL entry 2" in the list of Master Checklist items as child 0 of "Some other list (SOL)"
    And I should see the item named "SOL entry 0" in the list of Master Checklist items as child 1 of "Some other list (SOL)"
    And I should see the item named "SOL entry 1" in the list of Master Checklist items as child 2 of "Some other list (SOL)"
    And I should see the item named "SOL subentry 1.1" in the list of Master Checklist items as child 0 of "SOL entry 1"


  Scenario: Change the list position to the last item in the list. All other items are moved up (positions decremented)
    Given I am on the "manage checklist masters" page
    When I click on "SOL entry 0"
    Then I should see "SOL entry 0" in the h1 title
    When I click on t("admin_only.master_checklists.action_buttons.edit_list_item")
    And I fill in "master-list-position" with "3"
    And I click on the t("submit") button
    Then I should see t("admin_only.master_checklists.update.success", name: "SOL entry 0")

    When I am on the "manage checklist masters" page
    Then I should see the item named "SOL entry 2" in the list of Master Checklist items as child 1 of "Some other list (SOL)"
    And I should see the item named "SOL entry 0" in the list of Master Checklist items as child 2 of "Some other list (SOL)"
    And I should see the item named "SOL entry 1" in the list of Master Checklist items as child 0 of "Some other list (SOL)"
    And I should see the item named "SOL subentry 1.1" in the list of Master Checklist items as child 0 of "SOL entry 1"


  Scenario: Change the list position to the middle of the list. Other list item positions are changed appropriately
    Given I am on the "manage checklist masters" page
    When I click on "SOL entry 0"
    Then I should see "SOL entry 0" in the h1 title
    When I click on t("admin_only.master_checklists.action_buttons.edit_list_item")
    And I fill in "master-list-position" with "2"
    And I click on the t("submit") button
    Then I should see t("admin_only.master_checklists.update.success", name: "SOL entry 0")

    When I am on the "manage checklist masters" page
    Then I should see the item named "SOL entry 2" in the list of Master Checklist items as child 2 of "Some other list (SOL)"
    And I should see the item named "SOL entry 0" in the list of Master Checklist items as child 1 of "Some other list (SOL)"
    And I should see the item named "SOL entry 1" in the list of Master Checklist items as child 0 of "Some other list (SOL)"
    And I should see the item named "SOL subentry 1.1" in the list of Master Checklist items as child 0 of "SOL entry 1"


  # -----------------
  # DELETE Master checklists

  Scenario: Delete an item that is a sub-item of a checklist
    Given I am on the "manage checklist masters" page
    When I click on "Provide co nummer"
    Then I should see "Provide co nummer" in the h1 title
    When I click on t("admin_only.master_checklists.delete_button_if_applicable.delete", name: "Provide co nummer")
    Then I should see t("admin_only.master_checklists.index.title") in the h1 title
    And I should see 13 Master Checklist listed

    And I should not see "Provide co nummer" in the "archived-items" table
    And I should see "Submit yer app" in the "archived-items" table


  Scenario: Delete an item that has sub-items (sublists)
    Given I am on the "manage checklist masters" page
    When I click on "Submit yer app"
    Then I should see "Submit yer app" in the h1 title
    And I should see t("admin_only.master_checklists.delete_button_if_applicable.delete", name: "Submit yer app")
    When I click on t("admin_only.master_checklists.delete_button_if_applicable.delete", name: "Submit yer app")
    Then I should see t("admin_only.master_checklists.index.title") in the h1 title
    And I should see 11 Master Checklist listed

    # The checklist and all children were deleted
    And I should not see "Submit yer app" in the "archived-items" table
    And I should not see "Provide co nummer" in the "archived-items" table
    And I should not see "Document Business Categories" in the "archived-items" table
