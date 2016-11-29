Feature: As an applicant
  In order to be able to edit my application
  I want to be allowed to do that

  PT: https://www.pivotaltracker.com/story/show/134078325


  Background:
    Given the following users exists
      | email                  |
      | applicant_1@random.com |
      | applicant_2@random.com |

    And the following applications exist:
      | first_name | user_email             |
      | Emma       | applicant_1@random.com |
      | Hans       | applicant_2@random.com |

  Scenario: Applicant wants to edit his own application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "landing" page
    And I click on "My Application"
    Then I should be on "Edit My Application" page
    And I fill in "First Name" with "Anna"
    And I click on "Submit"
    Then I should see "Membership Application successfully updated"
    And I should be on the application page for "Anna"
    And I should see "Anna Lastname"

  Scenario: Applicant makes mistake when editing his own application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "landing" page
    And I click on "My Application"
    Then I should be on "Edit My Application" page
    And I fill in "Contact Email" with "sussimmi.nu"
    And I click on "Submit"
    Then I should see "A problem prevented the membership application to be saved"
    And I should be on "Edit My Application" page

  Scenario: Applicant can not edit applications not created by him
    Given I am logged in as "applicant_1@random.com"
    And I navigate to the edit page for "Hans"
    Then I should see "You are not authorized to perform this action."