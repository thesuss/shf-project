Feature: As a visitor
  In order to get a membership with SHF (which makes my business more valuable )
  I need to be able to submit a Membership Application

  PT: https://www.pivotaltracker.com/story/show/133940725
  &: https://www.pivotaltracker.com/story/show/135027425

  Background:
    Given the following users exists
      | email                  |
      | applicant_1@random.com |
    And the following business categories exist
      | name    |
      | Groomer |
    And I am logged in as "applicant_1@random.com"

  Scenario: Visitor can submit a new Membership Application
    Given I am on the "landing" page
    And I click on "Apply for membership"
    And I fill in "First Name" with "Kicki"
    And I fill in "Last Name" with "Andersson"
    And I select "Groomer" Category
    And I fill in "Company Number" with "5562252998"
    And I fill in "Contact Email" with "info@craft.se"
    And I fill in "Phone Number" with "031-1234567"
    And I click on "Submit"
    Then I should be on the landing page
    And I should see "Thank you, Your application has been submitted"

  Scenario Outline: Apply for membership - when things go wrong
    Given I am on the "landing" page
    And I click on "Apply for membership"
    When I fill in the form with data :
      | First Name | Last Name | Company Number | Contact Email | Phone Number |
      | <f_name>   | <l_name>  | <c_number>     | <c_email>     | <phone>      |
    When I click on "Submit"
    Then I should see <error>

    Scenarios:
      | f_name | c_number   | l_name     | c_email       | phone      | error                                                          |
      | Kicki  | 00         | Andersson  | kicki@immi.nu | 0706898525 | "Company number is the wrong length (should be 10 characters)" |
      | Kicki  |            | Andersson  | kicki@immi.nu | 0706898525 | "Company number can't be blank"                                |
      | Kicki  | 5562252998 |            | kicki@immi.nu | 0706898525 | "Last name can't be blank"                                     |
      | Kicki  | 5562252998 | Andersson  |               | 0706898525 | "Contact email can't be blank"                                     |
      |        | 5562252998 | Andersson  | kicki@immi.nu | 0706898525 | "First name can't be blank"                                    |
      | Kicki  | 5562252998 | Andersson  | kicki@imminu  | 0706898525 | "Contact email is invalid"                                     |
      | Kicki  | 5562252998 | Andersson  | kickiimmi.nu  | 0706898525 | "Contact email is invalid"                                     |