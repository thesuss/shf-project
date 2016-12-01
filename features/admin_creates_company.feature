Feature: As an admin
  So that I can view and manage companies
  I need to be able to create them

  Companies are created when a membership application is approved. That
  will not have any user interaction, but we need to have companies
  exist and the admin needs to be able to see the list of them.

  This feature exercises what happens when a company is created and is the
  basis for a member being able to edit their company page.

  PT:  https://www.pivotaltracker.com/story/show/133081453

  Background:
    Given the following users exists
      | email                      | admin |
      | applicant_1@happymutts.com |       |
      | admin@shf.se               | true  |

    And the following companies exist:
      | name                 | company_number | email                  |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com |
      | Bowsers              | 2120000142     | bowwow@bowsersy.com    |

    And the following applications exist:
      | first_name | user_email                 | company_number | status   |
      | Emma       | applicant_1@happymutts.com | 5562252998     | approved |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Awesome      |

  Scenario: Admin creates a company
    Given I am logged in as "admin@shf.se"
    When I am on the "create a new company" page
    And I fill in the form with data :
      | Name        | Organization Number | Street         | Post Code | City   | Region    | Email                | Website                   |
      | Happy Mutts | 5562252998          | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kicki@gladajyckar.se | http://www.gladajyckar.se |
    And I select "Groomer" Category
    And I select "Trainer" Category
    And I click on "Submit"
    Then I should see "The company was successfully created."
    And I should see "Company: Happy Mutts"
    And I should see "123 45"
    And I should see "Bromma"
    And I should see "Groomer"
    And I should see "Trainer"


  Scenario Outline: Admin creates company - when things go wrong
    Given I am logged in as "admin@shf.se"
    When I am on the "create a new company" page
    And I fill in the form with data :
      | Name   | Organization Number | Email   | Phone Number | Street   | Post Code   | City   | Region   | Website   |
      | <name> | <org_number>        | <email> | <phone>      | <street> | <post_code> | <city> | <region> | <website> |
    When I click on "Submit"
    Then I should see <error>
    And I should see "A problem prevented the company from being created."

    Scenarios:
      | name        | org_number | phone      | street         | post_code | city   | region    | email                | website                   | error                                                          |
      | Happy Mutts | 00         | 0706898525 | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kicki@gladajyckar.se | http://www.gladajyckar.se | "Company number is the wrong length (should be 10 characters)" |
      | Happy Mutts | 5562252998 |            | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kickiimmi.nu         | http://www.gladajyckar.se | "Email is invalid"                                             |
      | Happy Mutts | 5562252998 |            | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kicki@imminu         | http://www.gladajyckar.se | "Email is invalid"                                             |


  Scenario: Admin edits a company
    Given I am logged in as "admin@shf.se"
    When I am on the "all companies" page
    And I click the "Edit" action for the row with "5560360793"
    And I fill in the form with data :
      | Email                | Website                      |
      | kicki@gladajyckar.se | http://www.snarkybarkbark.se |
    And I select "Groomer" Category
    And I select "Trainer" Category
    And I click on "Submit"
    Then I should see "The company was successfully updated."
    And I should see "kicki@gladajyckar.se"
    And I should see "http://www.snarkybarkbark.se"

  Scenario Outline: Admin edits a company - when things go wrong (sad case)
    Given I am logged in as "admin@shf.se"
    When I am on the "all companies" page
    And I click the "Edit" action for the row with "5560360793"
    And I fill in the form with data :
      | Name   | Organization Number | Email   | Phone Number | Street   | Post Code   | City   | Region   | Website   |
      | <name> | <org_number>        | <email> | <phone>      | <street> | <post_code> | <city> | <region> | <website> |
    When I click on "Submit"
    Then I should see <error>
    And I should see "A problem prevented the company from being updated."

    Scenarios:
      | name        | org_number | phone      | street         | post_code | city   | region    | email                | website                   | error                                                          |
      | Happy Mutts | 00         | 0706898525 | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kicki@gladajyckar.se | http://www.gladajyckar.se | "Company number is the wrong length (should be 10 characters)" |
      | Happy Mutts | 5560360793 |            | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kickiimmi.nu         | http://www.gladajyckar.se | "Email is invalid"                                             |
      | Happy Mutts | 5560360793 |            | Ålstensgatan 4 | 123 45    | Bromma | Stockholm | kicki@imminu         | http://www.gladajyckar.se | "Email is invalid"                                             |


  Scenario: Admin sees all companies listed
    Given I am logged in as "admin@shf.se"
    When I am on the "all companies" page
    Then I should see 2 company rows

  Scenario: User tries to create a company
    Given I am logged in as "applicant_1@happymutts.com"
    And I am on the "create a new company" page
    Then I should see "You are not authorized to perform this action"

  Scenario: User tries to view all companies
    Given I am logged in as "applicant_1@happymutts.com"
    And I am on the "all companies" page
    Then I should see "You are not authorized to perform this action"

  Scenario: Visitor tries to view all companies
    Given I am Logged out
    And I am on the "all companies" page
    Then I should see "You are not authorized to perform this action"

  Scenario: Visitor tries to create a company
    Given I am Logged out
    And I am on the "create a new company" page
    Then I should see "You are not authorized to perform this action"
