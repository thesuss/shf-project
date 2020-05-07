Feature: Admin is able to check or uncheck items on a user checklist

  As an admin
  I need to be able to check or uncheck (mark complete or uncomplete) items for a user in a user's checklis
  So that I can help people unable to do it, and to keep information up to date and correct.


  Background:

    Given the date is set to "2020-02-02"
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                | admin | member | first_name | last_name |
      | applicant@random.com |       |        | Kicki      | Applicant |
      | member@random.com    |       | true   | Lars       | Member    |
      | admin@shf.se         | yes   |        |            |           |

#
#      | name                          | displayed_text   | list position | parent name       |
#      | Medlemsåtagande               | Medlemsåtagande  |               |                   |
#      | Section 1                     | Section 1        | 0             | Medlemsåtagande   |
#      | Guideline 1.1                 | Guideline 1.1    | 0             | Section 1         |
#      | Guideline 1.2                 | Guideline 1.2    | 1             | Section 1         |
#      | Section 2                     | Section 2        | 1             | Medlemsåtagande   |
#      | Guideline 2.1                 | Guideline 2.1    | 0             | Section 2         |


    Given the following user checklist items have been completed:
      | user email           | checklist name   | date completed |
      | applicant@random.com | Guideline 1.2    | 2020-02-03     |
      | applicant@random.com | Guideline 1.1    | 2020-02-02     |
      | member@random.com    | Medlemsåtagande | 2020-02-02     |



#
#  @time_adjust @selenium
#  Scenario: Admin checks a checklist item as completed and the date completed is shown
#    Given I am logged in as "member@random.com"
#    And the date is set to "2020-02-04"
#    And I am on the "my checklists" page
#    And show me the page
#    Then I should see the date completed as 2020-02-02 for the user checklist "Medlemsåtagande"


#    When I check the checkbox for the user checklist "Provide supporting documents"
#    Then I should see the date completed as 2019-12-20 for the user checklist "Provide supporting documents"
#    And the checkbox for the user checklist "Provide supporting documents" should be checked
#


#  @selenium
#  Scenario: Admin unchecks a checklist item as completed and the date completed is hidden
#    Given I am logged in as "applicant@random.com"
#    And I am on the "my checklists" page
#    Then I should see the date completed as 2019-12-12 for the user checklist "Complete the Application"
#
#    When I uncheck the checkbox for the user checklist "Complete the Application"
#    Then the checkbox for the user checklist "Complete the Application" should not be checked
#    And I should not see a date completed for the user checklist "Complete the Application"


#  @selenium
#  Scenario: A checklist with children cannot be checked as completed. It should be disabled
#    Given I am logged in as "member@random.com"
#    And I am on the "my checklists" page
#
#    Then I should not see a date completed for the user checklist "Guideline section 1"
#    And I should not see a date completed for the user checklist "text displayed to the user for Guideline 1.1"
#    And I should see the date completed as 2020-02-02 for the user checklist "text displayed to the user for Guideline 1.2"
#    And I should see the date completed as 2020-03-03 for the user checklist "text displayed to the user for Guideline 1.3"
#    And the checkbox for the user checklist "Guideline section 1" should be disabled


#  @time_adjust @selenium
#  Scenario: The last sub-item is checked complete and the parent list checkbox is automatically checked and also shows the date completed
#    Given I am logged in as "member@random.com"
#    And the date is set to "2020-06-06"
#    And I am on the "my checklists" page
#    Then I should not see a date completed for the user checklist "Guideline section 1"
#    And I should not see a date completed for the user checklist "text displayed to the user for Guideline 1.1"
#    Then I should see a date completed for the user checklist "text displayed to the user for Guideline 1.2"
#    And I should see the date completed as 2020-02-02 for the user checklist "text displayed to the user for Guideline 1.2"
#    And I should see the date completed as 2020-03-03 for the user checklist "text displayed to the user for Guideline 1.3"
#
#    When I check the checkbox for the user checklist "text displayed to the user for Guideline 1.1"
#    Then the checkbox for the user checklist "text displayed to the user for Guideline 1.1" should be checked
#    And I should see the date completed as 2020-06-06 for the user checklist "text displayed to the user for Guideline 1.1"
#    And I should see the date completed as 2020-06-06 for the user checklist "Guideline section 1"
#    And the checkbox for the user checklist "Guideline section 1" should be checked
#
#    # These are not changed
#    And I should see the date completed as 2020-02-02 for the user checklist "text displayed to the user for Guideline 1.2"
#    And I should see the date completed as 2020-03-03 for the user checklist "text displayed to the user for Guideline 1.3"
