Feature: As an Admin
  In order to get members into SHF and get their money
  I need to be able to accept/reject their application
  PT: https://www.pivotaltracker.com/story/show/133950603

Background:
  Given the following applications exist:
    | company_name | company_number | contact_person | phone_number | company_email |
    | DoggieZone   | 2345678901     | Pam Andersson  | 0234-234567  | din@mail.se   |

Scenario: Flag a Membership Application as approved
  Given I am on "DoggieZone" application page
  When I set "status" to "approved"
  And I click on "Submit"
  Then I should see "Membership Application successfully approved"


