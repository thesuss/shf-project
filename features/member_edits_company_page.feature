Feature: As a member
  So that visitors can see if my company offers services they might be interested in
  I need to be able to set a page that displays information about my company

  PT:  https://www.pivotaltracker.com/story/show/133081453

  Background:
    Given the following users exists
      | email                  | admin | is_member |
      | applicant_1@random.com |       | true      |
      | applicant_2@random.com |       |           |
      | admin@shf.se           | true  |           |


    And the following applications exist:
      | first_name | user_email             | status   |
      | Emma       | applicant_1@random.com | approved |


  Scenario: Member goes to company page after membership approval
    Given I am logged in as "applicant_1@random.com"
    And I click on "my company page"
    And I click on "Submit"
    Then I should see "The company information was saved successfully."
    And I should be on "" page
    And I should see ""



  Scenario: User tries to go do company page (sad path)
    Given I am logged in as "applicant_2@random.com"
    And I am on the "my company page" page
    Then I should see "You are not authorized to do that action"

