Feature: Access to Master Checklists (who can see/do what with master checklists)

  A "master checklist" is a list with entries that can be nested and are in order.
  It is the basis/template for User Checklists.
  Only an admin can create, edit, or delete them.

  Background:

    Given the date is set to "2018-01-01"
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


    Given the following companies exist:
      | name       | company_number | email               | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com | Stockholm |

    Given the following applications exist:
      | user_email    | company_number | state    |
      | member@shf.se | 2120000142     | accepted |

    Given the following payments exist
      | user_email    | start_date | expire_date | payment_type | status | hips_id |
      | member@shf.se | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |


  Scenario: Admin can see all Master lists.
    Given I am logged in as "admin@shf.se"
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title")
    And I should see 10 Master Checklist listed


  Scenario: Admin can edit all Master Lists
    Given I am logged in as "admin@shf.se"
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title")
    And I should see 10 Master Checklist listed


  Scenario: Admin can delete all Master Lists
    Given I am logged in as "admin@shf.se"
    Given I am on the "manage checklist masters" page
    Then I should see t("admin_only.master_checklists.index.title")
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
