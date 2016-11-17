Feature: As a registered user
  in order to access the functions of the site
  I need to be able to login

  Background:
    Given the following users exists
      | email             | password |
      | emma@random.com   | password |
      | anne@random.com   | password |

    And the following applications exist:
      | company_name       | user_email      |
      | My Dog Business    | emma@random.com |

  Scenario: Logging in
    Given I am on the "landing" page
    Then I should see "Login"
    When I click on "Login"
    Then I should be on "login" page
    When I fill in "Email" with "emma@random.com"
    And I fill in "Password" with "password"
    And I click on "Log in"
    Then I should see "Signed in successfully"

  Scenario: Not proper e-mail
    Given I am on the "login" page
    When I fill in "Email" with "emmarandom.com"
    And I fill in "Password" with "password"
    And I click on "Log in"
    Then I should see "Invalid Email or password"

  Scenario: No input of email
    Given I am on the "login" page
    When I leave the "Email" field empty
    And I click on "Log in"
    Then I should see "Invalid Email or password"

  Scenario: No input of password
    Given I am on the "login" page
    When I leave the "Password" field empty
    And I click on "Log in"
    Then I should see "Invalid Email or password"

  Scenario: Not registered user
    Given I am on the "login" page
    When I fill in "Email" with "anna@random.com"
    And I fill in "Password" with "password"
    And I click on "Log in"
    Then I should see "Invalid Email or password"

  Scenario: Not accessing protected page
    Given I am on the "login" page
    When I fill in "Email" with "anna@random.com"
    And I fill in "Password" with "password"
    And I click on "Log in"
    Then I should see "Invalid Email or password"
    When I fail to visit the "applications index" page
    Then I should see "You are not authorized to perform this action."
    And I should be on "landing" page