@parallel_group1 @admin
Feature: Admin is able to check or uncheck items on a user checklist

  As an admin
  I need to be able to check or uncheck (mark complete or uncomplete) items for a user in a user's checklis
  So that I can help people unable to do it,
  and to keep information up to date and correct.

  Background:

    Given the date is set to "2020-02-02"
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                | admin | member | first_name | last_name |
      | applicant@random.com |       |        | Kicki      | Applicant |
      | member@random.com    |       | true   | Lars       | Member    |
      | admin@shf.se         | yes   |        |            |           |
      | new_user@example.com |       |        | New        | User      |


    Given the following user checklist items have been completed:
      | user email           | checklist name   | date completed |
      | applicant@random.com | Guideline 1.2    | 2020-02-03     |
      | applicant@random.com | Guideline 1.1    | 2020-02-02     |
      | member@random.com    | Medlemsåtagande | 2020-02-02     |

  # ---------------------------

  @selenium @javascript
  Scenario: Admin checks a checklist item as completed and the date completed is shown
    Given I am logged in as "admin@shf.se"
    And the date is set to "2020-03-01"
    And I am on the "checklists" page for "applicant@random.com"
    Then the checkbox for the user checklist "Guideline 2.1" should not be checked
    When I check the checkbox for the user checklist "Guideline 2.1"
    And I wait for all ajax requests to complete
    Then the checkbox for the user checklist "Guideline 2.1" should be checked
    And I should see the date completed as 2020-03-01 for the user checklist "Guideline 2.1"


  @selenium @javascript
  Scenario: Admin unchecks a checklist item as completed and the date completed is hidden
    Given I am logged in as "admin@shf.se"
    And the date is set to "2020-03-01"
    And I am on the "checklists" page for "applicant@random.com"
    Then the checkbox for the user checklist "Guideline 1.1" should be checked
    When I uncheck the checkbox for the user checklist "Guideline 1.1"
    Then the checkbox for the user checklist "Guideline 1.1" should not be checked
    And I should not see a date completed for the user checklist "Guideline 1.1"


  @selenium @javascript
  Scenario: A checklist with children cannot be checked as completed. It should be disabled
    Given I am logged in as "admin@shf.se"
    And the date is set to "2020-03-01"
    And I am on the "checklists" page for "applicant@random.com"
    Then the checkbox for the user checklist "Guideline 2.1" should not be checked

    And the checkbox for the user checklist "Section 2" should be disabled



#  @selenium @javascript
#  TODO: Scenario: The last sub-item is checked complete and the parent list checkbox is automatically checked and also shows the date completed
#    Given I am logged in as "admin@shf.se"
#    And the date is set to "2020-03-01"
#    And I am on the "checklists" page for "applicant@random.com"
#    Then I should not see a date completed for the user checklist "Section 2"
#    And I should not see a date completed for the user checklist "Guideline 2.1"
#
#    When I check the checkbox for the user checklist "Guideline 2.1"
#    Then the checkbox for the user checklist "Guideline 2.1" should be checked
#    And I should see the date completed as 2020-03-01 for the user checklist "Guideline 2.1"
#    And I should see the date completed as 2020-03-01 for the user checklist "Section 2"
#    And the checkbox for the user checklist "Section 2" should be checked
