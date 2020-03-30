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


#  Background:
#
#    Given the following users exist:
#      | email        | admin | member |
#      | admin@shf.se | true  |        |
#
#    Given I am logged in as "admin@shf.se"
#
#
#    Given the following Master Checklist exist:
#      | name                         | displayed_text               | description                                                | list position | parent name           |
#      | Submit yer app               | Submit Your Application      | top level list with no parent                              | 0             | Membership            |
#      | Yer Biz Cats                 | Your Business Categories     | Indicate your business categories (skills)                 | 0             | Submit yer app        |
#      | Provide co nummer            | Provide Company Number       | provide the Org Nm. for at least 1 company                 | 1             | Submit yer app        |
#      | Document Business Categories | Document Business Categories | Provide documents for your business categories (skills)    | 2             | Submit yer app        |
#      | Membership                   | Membership                   | Complete and submit a membership application               |               |                       |
#      | SHF Approved it              | SHF Approved Application     | SHF has approved your application                          | 1             | Membership            |
#      | Pay your membership fee      | Pay your membership fee      | Pay your membership (good for 1 year)                      | 2             | Membership            |
#      | Some other list (SOL)        | some list                    | some other top level list                                  |               |                       |
#      | SOL entry 0                  | sol 0                        | entry 0 in Some other list (SOL); not a list (no children) | 0             | Some other list (SOL) |
#      | SOL entry 2                  | sol 2                        | entry 2 in Some other list (SOL); not a list (no children) | 2             | Some other list (SOL) |
#      | SOL entry 1                  | sol 1                        | entry 1 in Some other list (SOL); not a list (no children) | 1             | Some other list (SOL) |
#
#
#
#  # ----------------------
#  # VIEW (read) Master checklists
#  # UX: Can edit/view all items in the list (linked, buttons, or icons or something)
#
#  Scenario: See all checklists on the manage checklists page
#    Given I am on the "manage checklist masters" page
#    Then I should see t("admin_only.master_checklists.index.title")
#    And I should see 11 Master Checklist listed
#
#    # Verify that all entries are shown - these are the _names_ (not the displayed text)
#    And I should see the item named "Submit yer app" in the list of Master Checklist items as child 0
#    And I should see the item named "Yer Biz Cats" in the list of Master Checklist items as child 0 of "Submit yer app"
#    And I should see the item named "Provide co nummer" in the list of Master Checklist items as child 1 of "Submit yer app"
#    And I should see the item named "Document Business Categories" in the list of Master Checklist items as child 2 of "Submit yer app"
#
#    And I should see the item named "Membership" in the list of Master Checklist items as child 1
#    And I should see the item named "SHF Approved it" in the list of Master Checklist items as child 0 of "Membership"
#    And I should see the item named "Pay your membership fee" in the list of Master Checklist items as child 1 of "Membership"
#
#    And I should see the item named "Some other list (SOL)" in the list of Master Checklist items as child 2
#    And I should see the item named "SOL entry 0" in the list of Master Checklist items as child 0 of "Some other list (SOL)"
#    And I should see the item named "SOL entry 1" in the list of Master Checklist items as child 1 of "Some other list (SOL)"
#    And I should see the item named "SOL entry 2" in the list of Master Checklist items as child 2 of "Some other list (SOL)"
#
#
#  Scenario: Clicking on an entry name will go to the view for it
#    Given I am on the "manage checklist masters" page
#    Then I should see t("admin_only.master_checklists.index.title")
#    When I click on "SOL entry 0"
#    Then I should see "SOL entry 0" in the h1 title
#    And I should see t("admin_only.master_checklists.show.displayed_text")
#    And I should see t("admin_only.master_checklists.show.edit_list_item")
#
#
#  Scenario: Clicking on the displayed text for an entry will go to the view for it
#    Given I am on the "manage checklist masters" page
#    Then I should see t("admin_only.master_checklists.index.title")
#    When I click on "some list" link
#    Then I should see "Some other list (SOL)" in the h1 title
#
#
#  Scenario: The parent list for an entry is shown and clicking on it goes to the view for the parent
#    Given I am on the page for Master Checklist item named "SOL entry 0"
#    Then I should see "SOL entry 0" in the h1 title
#    And I should see "Some other list (SOL)"
#    When I click on "Some other list (SOL)"
#    Then I should see "Some other list (SOL)" in the h1 title
#
#
#  # -----------------
#  # CREATE Master checklists
#
#  Scenario: Create a new item and do not pick a parent list. It should show on the list of checklists on the manage checklists page at the top level
#    Given I am on the "manage checklist masters" page
#    Then I should see t("admin_only.master_checklists.index.title")
#    When I click on the t("admin_only.master_checklists.index.new_item") link
#    Then I should see t("admin_only.master_checklists.new.title")
#    When I fill in t("admin_only.master_checklists.form.name") with "A new checklist"
#    And I fill in t("admin_only.master_checklists.form.displayed_text") with "Shiny New Checklist"
#    And I fill in t("admin_only.master_checklists.form.description") with "description for this new checklist"
#    And I click on the t("submit") button
#    Then I should see t("admin_only.master_checklists.create.success", name: "A new checklist")
#    And I should see "A new checklist" in the h1 title
#
#    When I am on the "manage checklist masters" page
#    Then I should see the item named "A new checklist" in the list of Master Checklist items as child 3
#
#
#  Scenario: Create an item in a list and specify the position. Position should be right and others in the list should be adjusted.
#    Given I am on the "manage checklist masters" page
#    Then I should see t("admin_only.master_checklists.index.title")
#    When I click on the t("admin_only.master_checklists.index.new_item") link
#    Then I should see t("admin_only.master_checklists.new.title")
#    When I fill in t("admin_only.master_checklists.form.name") with "Inserted as 2nd item"
#    And I fill in t("admin_only.master_checklists.form.displayed_text") with "Some Other List - another one"
#    And I fill in t("admin_only.master_checklists.form.description") with "description for this new checklist"
#    And I select "Some other list (SOL)" as the parent list
#    # TODO I can't figure out why I have to use the #id of the input field below to have Capybara find it
#    And I fill in "master-list-position" with "1"
#    And I click on the t("submit") button
#
#    Then I should see t("admin_only.master_checklists.create.success", name: "Inserted as 2nd item")
#    And I should see "Inserted as 2nd item" in the h1 title
#
#    When I am on the "manage checklist masters" page
#    Then I should see the item named "Inserted as 2nd item" in the list of Master Checklist items as child 1 of "Some other list (SOL)"
#    And I should see the item named "SOL entry 0" in the list of Master Checklist items as child 0 of "Some other list (SOL)"
#    And I should see the item named "SOL entry 1" in the list of Master Checklist items as child 2 of "Some other list (SOL)"
#    And I should see the item named "SOL entry 2" in the list of Master Checklist items as child 3 of "Some other list (SOL)"
#
#
#  Scenario: Create an item in a list and do not specify the position. It should be put at the end
#    Given I am on the "manage checklist masters" page
#    Then I should see t("admin_only.master_checklists.index.title")
#    When I click on the t("admin_only.master_checklists.index.new_item") link
#    Then I should see t("admin_only.master_checklists.new.title")
#    When I fill in t("admin_only.master_checklists.new.name") with "Another SOL item"
#    And I fill in t("admin_only.master_checklists.new.displayed_text") with "Some Other List - another one"
#    And I fill in t("admin_only.master_checklists.new.description") with "description for this new checklist"
#    And I select "Some other list (SOL)" as the parent list
#    And I click on the t("submit") button
#    Then I should see t("admin_only.master_checklists.create.success", name: "Another SOL item")
#    And I should see "Another SOL item" in the h1 title
#
#    When I am on the "manage checklist masters" page
#    And I should see the item named "Another SOL item" in the list of Master Checklist items as child 3 of "Some other list (SOL)"
#
#
#  Scenario: Create an item in a list and specify the position that is the same as an item now marked as 'no longer in use'. Position should be right and others in the list should be adjusted.
#    Given I am on the "manage checklist masters" page
#    Then I should see t("admin_only.master_checklists.index.title")
#    When I click on the t("admin_only.master_checklists.index.new_item") link
#    Then I should see t("admin_only.master_checklists.new.title")
#    When I fill in t("admin_only.master_checklists.form.name") with "Inserted as 2nd item"
#    And I fill in t("admin_only.master_checklists.form.displayed_text") with "Some Other List - another one"
#    And I fill in t("admin_only.master_checklists.form.description") with "description for this new checklist"
#    And I select "Some other list (SOL)" as the parent list
#    # TODO I can't figure out why I have to use the #id of the input field below to have Capybara find it
#    And I fill in "master-list-position" with "1"
#    And I click on the t("submit") button
#
#    Then I should see t("admin_only.master_checklists.create.success", name: "Inserted as 2nd item")
#    And I should see "Inserted as 2nd item" in the h1 title
#
#    When I am on the "manage checklist masters" page
#    Then I should see the item named "Inserted as 2nd item" in the list of Master Checklist items as child 1 of "Some other list (SOL)"
#    And I should see the item named "SOL entry 0" in the list of Master Checklist items as child 0 of "Some other list (SOL)"
#    And I should see the item named "SOL entry 1" in the list of Master Checklist items as child 2 of "Some other list (SOL)"
#    And I should see the item named "SOL entry 2" in the list of Master Checklist items as child 3 of "Some other list (SOL)"
#
#  # ---------------
#  # EDIT Master checklists
#
#  Scenario: Rename a checklist that is a sublist in another list
#    # view the parent list(s); should see the rename
#    # any users associated with it will also see the change
#
#
#  Scenario: Change the status to 'no longer used'
#    # the date the status was changed is recorded
#
#
#  # ----------------
#  # Reordering Master checklists
#
#  Scenario: Change the list position to the first item in the list. All other items are moved down (positions incremented)
#
#
#  Scenario: Change the list position to the last item in the list. All other items are moved up (positions decremented)
#
#
#  Scenario: Change the list position to the middle of the list. Other list item positions are changed appropriately
#
#
#
#  # -----------------
#  # DELETE Master checklists
#
#  Scenario: Delete an item that is a sublist of other checklists
#
#  Scenario: Delete an item that has sub-items (a mix of sublists and entries)
#
#  Scenario: Delete an item that has no sub-items
#
#  Scenario: Cannot delete an item if user checklists are associated with it
