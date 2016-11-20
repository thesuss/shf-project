Feature: As a visitor
  In order to get a membership with SHF (which makes my business more valuable )
  I need to be able to submit a Membership Application

  PT: https://www.pivotaltracker.com/story/show/133940725

  Background:
    Given the following users exists
      | email                  |
      | applicant_1@random.com |

    And I am logged in as "applicant_1@random.com"

  Scenario: Visitor can submit a new Membership Application
    Given I am on the "landing" page
    And I click on "Apply for membership"
    And I fill in "Company Name" with "Craft Academy"
    And I fill in "Company Number" with "5562252998"
    And I fill in "Contact Person" with "Thomas"
    And I fill in "Company Email" with "info@craft.se"
    And I fill in "Phone Number" with "031-1234567"
    And I click on "Submit"
    Then I should be on the landing page
    And I should see "Thank you, Your application has been submitted"

  Scenario Outline: Apply for membership - when things go wrong
    Given I am on the "landing" page
    And I click on "Apply for membership"
    When I fill in the form with data :
      | Company Name | Company Number | Contact Person | Company Email | Phone Number |
      | <c_name>     | <c_number>     | <c_person>     | <c_email>     | <phone>      |
    When I click on "Submit"
    Then I should see <error>

    Scenarios:
      | c_name     | c_number   | c_person | c_email       | phone      | error                                                          |
      | HappyMutts | 00         | Kicki    | kicki@immi.nu | 0706898525 | "Company number 00 is not a valid company number" |
      | HappyMutts |            | Kicki    | kicki@immi.nu | 0706898525 | "Company number is not a valid company number"                                |
      | HappyMutts | 5562252998 |          | kicki@immi.nu | 0706898525 | "Contact person can't be blank"                                |
      | HappyMutts | 5562252998 | Kicki    |               | 0706898525 | "Company email can't be blank"                                 |
      |            | 5562252998 | Kicki    | kicki@immi.nu | 0706898525 | "Company name can't be blank"                                  |
      | HappyMutts | 5562252998 | Kicki    | kicki@imminu  | 0706898525 | "Company email is invalid"                                     |
      | HappyMutts | 5562252998 | Kicki    | kickiimmi.nu  | 0706898525 | "Company email is invalid"                                     |