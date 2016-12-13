Feature: As a registered user
  in order to access the functions of the site
  I need to be able to login

  Background:
    Given the following users exists
      | email                | password | admin | is_member |
      | emma@random.com      | password | false | true      |
      | anne@random.com      | password | false | false     |
      | lars-user@random.com | password | false | false     |
      | arne@random.com      | password | true  | true      |

    And the following applications exist:
      | first_name | user_email           | company_number | status  |
      | Emma       | emma@random.com      | 5562252998     | Godkänd |
      | Lars       | lars-user@random.com | 2120000142     | pending |

  Scenario: Logging in
    Given I am on the "landing" page
    Then I should see "Logga in"
    When I click on "Logga in" link
    Then I should be on "login" page
    When I fill in "Email" with "emma@random.com"
    And I fill in "Password" with "password"
    And I click on "Logga in" button
    Then I should see "Signed in successfully"

  Scenario: Not proper e-mail
    Given I am on the "login" page
    When I fill in "Email" with "emmarandom.com"
    And I fill in "Password" with "password"
    And I click on "Logga in" button
    Then I should see "Invalid Email or password"

  Scenario: No input of email
    Given I am on the "login" page
    When I leave the "Password" field empty
    And I click on "Logga in" button
    Then I should see "Invalid Email or password"

  Scenario: No input of password
    Given I am on the "login" page
    When I leave the "Password" field empty
    And I click on "Logga in" button
    Then I should see "Invalid Email or password"

  Scenario: Not registered user
    Given I am on the "login" page
    When I fill in "Email" with "anna@random.com"
    And I fill in "Password" with "password"
    And I click on "Logga in" button
    Then I should see "Invalid Email or password"

  Scenario: Not accessing protected page
    Given I am on the "login" page
    When I fill in "Email" with "anna@random.com"
    And I fill in "Password" with "password"
    And I click on "Logga in" button
    Then I should see "Invalid Email or password"
    When I fail to visit the "applications index" page
    Then I should see "Du har inte behörighet att göra detta."
    And I should be on "landing" page

  Scenario: Logging in as admin
    Given I am on the "landing" page
    Then I should see "Logga in"
    When I click on "Logga in" link
    Then I should be on "login" page
    When I fill in "Email" with "arne@random.com"
    And I fill in "Password" with "password"
    And I click on "Logga in" button
    Then I should see "Signed in successfully"
    And I should see "Admin:"
    And I should not see "Välkommen"
    And I should not see "Hej, kul att du är intresserad"

  Scenario: Logging in as a member
    Given I am on the "landing" page
    Then I should see "Logga in"
    When I click on "Logga in" link
    Then I should be on "login" page
    When I fill in "Email" with "emma@random.com"
    And I fill in "Password" with "password"
    And I click on "Logga in" button
    Then I should see "Välkommen"
    And I should not see "Admin:"
    And I should not see "Hej, kul att du är intresserad"

  Scenario: Logging in as a user
    Given I am on the "landing" page
    Then I should see "Logga in"
    When I click on "Logga in" link
    Then I should be on "login" page
    When I fill in "Email" with "lars-user@random.com"
    And I fill in "Password" with "password"
    And I click on "Logga in" button
    Then I should not see "Välkommen"
    And I should not see "Admin:"
    And I should see "Hej, kul att du är intresserad"
