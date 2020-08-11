Feature: Access to User checklists: the entire list, individual items, and via the account page

  An admin can always see the entire checklist for a user AND the checklist via the account page.
  A user and member can only see their checklist via the account page.
  Users and Members cannot see individual checklist item pages.

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                | admin | member | first_name | last_name |
      | new_user@example.com |       |        | NewUser1   | Applicant |
      | member@example.com   |       | true   | Lars       | Member    |
      | admin@shf.se         | true  |        |            |           |


    Given the following user checklist items have been completed:
      | user email           | checklist name   | date completed |
      | new_user@example.com | Guideline 1.2    | 2020-02-03     |
      | member@example.com   | Medlemsåtagande  | 2020-02-02     |

    And the following regions exist:
      | name      |
      | Stockholm |

    And the following companies exist:
      | name        | company_number | email               | region    |
      | Happy Mutts | 5560360793     | woof@happymutts.com | Stockholm |

    And the following business categories exist
      | name         | description   | subcategories          |
      | dog grooming | grooming dogs | light trim, custom cut |


    And the following applications exist:
      | user_email         | contact_email              | company_number | state    | categories   |
      | member@example.com | lars-member@happymutts.com | 5560360793     | accepted | dog grooming |

    And the following payments exist
      | user_email         | start_date | expire_date | payment_type | status | hips_id |
      | member@example.com | 2018-05-05 | 2019-05-04  | member_fee   | betald | none    |

  # ---------------------

  Scenario Outline: Visitor cannot see any checklists
    Given I am logged out
    Then I should get a routing error when I try to visit the "checklists" page


  Scenario Outline: Users and Members can view their own checklists via their account page
    Given I am logged in as "<shf_user>"
    When I am on the "user account" page
    Then I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    When I click on t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines") link
    Then I should not see a message telling me I am not allowed to see that page

    Scenarios:
      | shf_user             |
      | new_user@example.com |
      | member@example.com   |


  Scenario Outline: Users and Members cannot view an entire checklist (page)
    Given I am logged in as "<shf_user>"
    Then I should get a routing error when I try to visit the "checklists" page

    Scenarios:
      | shf_user             |
      | new_user@example.com |
      | member@example.com   |


  Scenario Outline: Users and Members cannot see an individual checklist item
    Given I am logged in as "<shf_user>"
    When I am on the page for checklist item "Guideline 1.1"
    Then I should see a message telling me I am not allowed to see that page

    Scenarios:
      | shf_user             |
      | new_user@example.com |
      | member@example.com   |


  Scenario Outline: Admin can see all checklist pages
    Given I am logged in as "admin@shf.se"
    When I am on the "checklists" page for <shf_user>
    Then I should not see a message telling me I am not allowed to see that page
    And I should see <expected_h1_text> in the h1 title

    Scenarios:
      | shf_user               | expected_h1_text                    |
      | "new_user@example.com" | "Checklists for NewUser1 Applicant" |
      | "member@example.com"   | "Checklists for Lars Member"        |


  Scenario Outline: Admin can see all checklists via account pages
    Given I am logged in as "admin@shf.se"
    When I am on the "user account" page for <shf_user>
    Then I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    When I click on t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines") link
    Then I should not see a message telling me I am not allowed to see that page

    Scenarios:
      | shf_user               |
      | "new_user@example.com" |
      | "member@example.com"   |


  Scenario: Admin can see an individual checklist item page
    Given I am logged in as "admin@shf.se"
    When I am on the page for checklist item "Guideline 1.1"
    Then I should not see a message telling me I am not allowed to see that page
    And I should see "Guideline 1.1" in the h1 title
