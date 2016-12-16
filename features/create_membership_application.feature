Feature: As a user
  In order to get a membership with SHF (which makes my business more valuable )
  I need to be able to submit a Membership Application
  PT: https://www.pivotaltracker.com/story/show/133940725
  &: https://www.pivotaltracker.com/story/show/135027425

  Secondary feature:
  As an admin
  So that we can minimize trouble signing up and sign up as many users as possible
  I would like required aspects of the membership form to be highlighted when they are missed
  PT: https://www.pivotaltracker.com/story/show/134192165

  Background:
    Given the following users exists
      | email                  |
      | applicant_1@random.com |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |

    And I am logged in as "applicant_1@random.com"

  Scenario: A user can submit a new Membership Application with 1 category
    Given I am on the "landing" page
    And I click on "Ansök om medlemsskap"
    And I fill in "Förnamn" with "Kicki"
    And I fill in "Efternamn" with "Andersson"
    And I select "Groomer" Category
    And I fill in "Org nr" with "5562252998"
    And I fill in "E-post" with "info@craft.se"
    And I fill in "Telefon" with "031-1234567"
    And I click on "Submit"
    Then I should be on the landing page
    And I should see "Tack, din ansökan har skickats."


  Scenario: A user can submit a new Membership Application with multiple categories
    Given I am on the "landing" page
    And I click on "Ansök om medlemsskap"
    And I fill in "Förnamn" with "Kicki"
    And I fill in "Efternamn" with "Andersson"
    And I select "Trainer" Category
    And I select "Psychologist" Category
    And I fill in "Org nr" with "5562252998"
    And I fill in "E-post" with "info@craft.se"
    And I fill in "Telefon" with "031-1234567"
    And I click on "Submit"
    Then I should be on the landing page
    And I should see "Tack, din ansökan har skickats."

  Scenario: A user can submit a new Membership Application with no categories selected
    Given I am on the "landing" page
    And I click on "Ansök om medlemsskap"
    And I fill in "Förnamn" with "Kicki"
    And I fill in "Efternamn" with "Andersson"
    And I fill in "Org nr" with "5562252998"
    And I fill in "E-post" with "info@craft.se"
    And I fill in "Telefon" with "031-1234567"
    And I click on "Submit"
    Then I should be on the landing page
    And I should see "Tack, din ansökan har skickats."

  Scenario: Applicant not see membership number when submitting
    Given I am on the "landing" page
    And I click on "Ansök om medlemsskap"
    Then I should not see "Medlemsnummer"

  Scenario: Applicant can see which fields are required
    Given I am on the "landing" page
    And I click on "Ansök om medlemsskap"
    Then the field "Förnamn" should have a required field indicator
    And the field "Org nr" should have a required field indicator
    And the field "Efternamn" should have a required field indicator
    And the field "E-post" should have a required field indicator
    And the field "Telefon" should not have a required field indicator
    And I should see "Indikerar ett obligatoriskt fält"

  Scenario Outline: Apply for membership - when things go wrong
    Given I am on the "landing" page
    And I click on "Ansök om medlemsskap"
    When I fill in the form with data :
      | Förnamn  | Efternamn | Org nr     | E-post    | Telefon |
      | <f_name> | <l_name>  | <c_number> | <c_email> | <phone> |
    When I click on "Submit"
    Then I should see translated error <model_attribute> <error>

    Scenarios:
      | f_name | c_number   | l_name    | c_email       | phone      | model_attribute                                                      | error                   |
      | Kicki  |            | Andersson | kicki@immi.nu | 0706898525 | activerecord.models.attributes.membership_application.company_number | errors.messages.blank   |
      | Kicki  | 5562252998 |           | kicki@immi.nu | 0706898525 | activerecord.models.attributes.membership_application.last_name      | errors.messages.blank   |
      | Kicki  | 5562252998 | Andersson |               | 0706898525 | activerecord.models.attributes.membership_application.contact_email  | errors.messages.blank   |
      |        | 5562252998 | Andersson | kicki@immi.nu | 0706898525 | activerecord.models.attributes.membership_application.first_name     | errors.messages.blank   |
      | Kicki  | 5562252998 | Andersson | kicki@imminu  | 0706898525 | activerecord.models.attributes.membership_application.contact_email  | errors.messages.invalid |
      | Kicki  | 5562252998 | Andersson | kickiimmi.nu  | 0706898525 | activerecord.models.attributes.membership_application.contact_email  | errors.messages.invalid |


  Scenario Outline: Apply for membership: company number wrong length
    Given I am on the "landing" page
    And I click on "Ansök om medlemsskap"
    When I fill in the form with data :
      | Förnamn  | Efternamn | Org nr     | E-post    | Telefon |
      | <f_name> | <l_name>  | <c_number> | <c_email> | <phone> |
    When I click on "Submit"
    Then I should see <error>
# Company number har fel längd (ska vara 10 tecken) Company number 00 är inte ett svenskt organisationsnummer
    Scenarios:
      | f_name | c_number | l_name    | c_email       | phone      | error                                                     |
      | Kicki  | 00       | Andersson | kicki@immi.nu | 0706898525 | t("errors.messages.wrong_length", count: 10), locale: :sv |
