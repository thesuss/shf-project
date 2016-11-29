Feature: As an Admin
  So that we can accept or reject new Memberships,
  I need to review a Membership Application that has been submitted
  PT: https://www.pivotaltracker.com/story/show/133950343

  Secondary feature:
  As an admin
  In order to handle new member applications
  I need to be able to log in to an admin part of the site

  PT: https://www.pivotaltracker.com/story/show/133080839

  Background:
    Given the following users exists
      | email                  | admin |
      | applicant_1@random.com |       |
      | applicant_2@random.com |       |
      | applican3_2@random.com |       |
      | admin@sgf.com          | true  |

    And the following applications exist:
      | first_name | user_email             | company_number |
      | Emma       | applicant_1@random.com | 1234567890     |
      | Hans       | applicant_2@random.com | 1234567899     |
      | Anna       | applicant_2@random.com | 1234567999     |


  Scenario: Listing incoming Applications open for Admin
    Given I am logged in as "admin@sgf.com"
    And I am on the list applications page
    Then I should see "3" applications
    When I click on "1234567890"
    Then I should be on the application page for "Emma"
    And I should see "Emma Lastname"
    And I should see "1234567890"


  Scenario: Listing incoming Applications restricted for Non-admins
    Given I am logged in as "applicant_2@random.com"
    And I am on the list applications page
    Then I should see "You are not authorized to perform this action."
