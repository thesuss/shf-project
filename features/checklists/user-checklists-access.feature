Feature: Access to User checklists

  An admin can always see all checklists.
  Users and members  can only see the checklists that belong to them.


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                     | admin | member | first_name | last_name |
      | new_user@example.com      |       |        | NewUser1   | Applicant |
      | applicant@random.com      |       |        | Applicant2 | Applicant |
      | member@random.com         |       | true   | Lars       | Member    |
      | another-member@random.com |       | true   | Another    | Member    |
      | admin@shf.se              | true  |        |            |           |


  Scenario Outline: Visitor cannot see any checklists
    Given I am logged out
    When I am on the "checklists" page for <shf_user>
    Then I should see a message telling me I am not allowed to see that page

    Scenarios:
      | shf_user                    |
      | "new_user@example.com"      |
      | "applicant@random.com"      |
      | "member@random.com"         |
      | "another-member@random.com" |


  Scenario: User can view their own checklists
    Given I am logged in as "applicant@random.com"
    When I am on the "checklists" page for "applicant@random.com"
    Then I should not see a message telling me I am not allowed to see that page
    And I should see "Checklists for Applicant2 Applicant" in the h1 title


  Scenario: User cannot see another user's checklist
    Given I am logged in as "new_user@example.com"
    When I am on the "checklists" page for "applicant@random.com"
    Then I should see a message telling me I am not allowed to see that page


  Scenario: User cannot see another member's checklist
    Given I am logged in as "new_user@example.com"
    When I am on the "checklists" page for "member@random.com"
    Then I should see a message telling me I am not allowed to see that page


  Scenario: Member can view their own checklists
    Given I am logged in as "member@random.com"
    When I am on the "checklists" page for "member@random.com"
    Then I should not see a message telling me I am not allowed to see that page
    And I should see "Checklists for Lars Member" in the h1 title


  Scenario: Member cannot see another user's checklist
    Given I am logged in as "member@random.com"
    When I am on the "checklists" page for "another-member@random.com"
    Then I should see a message telling me I am not allowed to see that page


  Scenario: Member cannot see another member's checklist
    Given I am logged in as "member@random.com"
    When I am on the "checklists" page for "another-member@random.com"
    Then I should see a message telling me I am not allowed to see that page


  Scenario Outline: Admin can see all checklists
    Given I am logged in as "admin@shf.se"
    When I am on the "checklists" page for <shf_user>
    Then I should not see a message telling me I am not allowed to see that page
    And I should see <expected_h1_text> in the h1 title

    Scenarios:
      | shf_user                    | expected_h1_text                      |
      | "new_user@example.com"      | "Checklists for NewUser1 Applicant"   |
      | "applicant@random.com"      | "Checklists for Applicant2 Applicant" |
      | "member@random.com"         | "Checklists for Lars Member"          |
      | "another-member@random.com" | "Checklists for Another Member"       |
