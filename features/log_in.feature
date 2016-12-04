Feature: As a registered user
  in order to access the functions of the site
  I need to be able to login

  Background:
    Given the following users exists
      | email           | password |
      | emma@random.com | password |
      | anne@random.com | password |

    And the following applications exist:
      | first_name | user_email      | company_number |
      | Emma       | emma@random.com | 5562252998     |

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