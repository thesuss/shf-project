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
      | applicant_3@random.com |       |
      | admin@sgf.com          | true  |

    And the following applications exist:
      | first_name | user_email             | company_number |
      | Emma       | applicant_1@random.com | 1234567890     |
      | Hans       | applicant_2@random.com | 1234567899     |
      | Anna       | applicant_3@random.com | 1234567999     |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |

  Scenario: Listing incoming Applications open for Admin
    Given I am logged in as "admin@sgf.com"
    And I am on the list applications page
    Then I should see "3" applications
    And I click the "Manage" action for the row with "1234567890"
    Then I should be on the application page for "Emma"
    And I should see "Emma Lastname"
    And I should see "1234567890"

  Scenario: Admin can see an application with one business categories given
    Given I am logged in as "applicant_2@random.com"
    And I am on the "landing" page
    And I click on "My Application"
    And I select "Groomer" Category
    And I click on "Submit"
    And I am Logged out
    And I am logged in as "admin@sgf.com"
    And I am on the list applications page
    Then I should see "3" applications
    And I click the "Manage" action for the row with "1234567899"
    Then I should be on the application page for "Hans"
    And I should see "Hans Lastname"
    And I should see "1234567899"
    And I should see "Groomer"
    And I should not see "Trainer"
    And I should not see "Psychologist"

  Scenario: Admin can see an application with multiple business categories given
    Given I am logged in as "applicant_1@random.com"
    And I am on the "landing" page
    And I click on "My Application"
    And I select "Trainer" Category
    And I select "Psychologist" Category
    And I click on "Submit"
    And I am Logged out
    And I am logged in as "admin@sgf.com"
    And I am on the list applications page
    Then I should see "3" applications
    And I click the "Manage" action for the row with "1234567890"
    Then I should be on the application page for "Emma"
    And I should see "Emma Lastname"
    And I should see "1234567890"
    And I should see "Trainer"
    And I should see "Psychologist"
    And I should not see "Groomer"

  Scenario: Listing incoming Applications restricted for Non-admins
    Given I am logged in as "applicant_2@random.com"
    And I am on the list applications page
    Then I should see "You are not authorized to perform this action."
