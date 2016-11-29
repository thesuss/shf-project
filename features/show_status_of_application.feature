Feature: As an Admin
  In order to get an easy overview of applications
  I need to see the status listed
  PT: https://www.pivotaltracker.com/story/show/134357317

  Background:
    Given the following users exists
      | email                  | admin |
      | din@mail.se            |       |
      | admin@sgf.com          | true  |

    And the following applications exist:
      | company_number | user_email  | status   |
      | 1234567890     | din@mail.se | Pending  |
      | 1234567899     | min@mail.se | Accepted |

    And I am logged in as "admin@sgf.com"

  Scenario: Showing status in the application listing
    Given I am logged in as "admin@sgf.com"
    And I am on the list applications page
    Then I should see "2" applications
    And I should see "Status"
    And I should see "Pending"
    And I should see "Accepted"
    