Feature: Access to Master Checklists

  A "master checklist" is a list with entries that can be nested and are in order.
  It is the basis/template for User Checklists.
  Only an admin can see them.


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email         | admin | member |
      | admin@shf.se  | true  |        |
      | member@shf.se |       | true   |
      | user@shf.se   |       |        |


    Given the following Master Checklist exist:
      | name                     | displayed_text                            | list position | parent name |
      | Membership               | Membership                                |               |             |
      | Submit Your Application  | Submit Your Application                   | 0             | Membership  |
      | SHF Approved Application | SHF Approved Application                  | 1             | Membership  |
      | Pay your membership fee  | Pay your membership fee (good for 1 year) | 2             | Membership  |


  Scenario: Admin can see all Master lists.
    Given I am logged in as "admin@shf.se"
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title") in the h1 title
    And I should see 10 Master Checklist listed


  Scenario: Visitor cannot see any Master Lists
    Given I am logged out
    Then I should get a routing error when I try to visit the "manage checklist masters" page


  Scenario: User cannot see any Master Lists
    Given I am logged in as "user@shf.se"
    Then I should get a routing error when I try to visit the "manage checklist masters" page


  Scenario: Member cannot see any Master Lists
    Given I am logged in as "member@shf.se"
    Then I should get a routing error when I try to visit the "manage checklist masters" page
