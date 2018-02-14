Feature: As a Member
  So that I can get the correct information
  Landing page should show correct information

  PT: https://www.pivotaltracker.com/story/show/135683887

  Background:
    Given the following users exist
      | email           | admin | member | membership_number |
      | anna@muffs.com  |       | false  |                   |
      | fanny@mutts.com |       | true   | 1002              |
      | emma@mutts.com  |       | true   | 1001              |
      | admin@shf.se    | true  | false  |                   |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com | 2017-10-1  | 2018-02-27  | member_fee   | betald | none    |

    Given the following companies exist:
      | name       | company_number | email                 | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com   | Stockholm |
      | HappyMuffs | 6222279082     | woof@happymuffs.com   | Stockholm |

    Given the following applications exist:
      | user_email      | company_number | category_name | state         |
      | emma@mutts.com  | 2120000142     | rehab         | accepted      |
      | anna@muffs.com  | 6222279082     | other         | under_review  |
      | fanny@mutts.com | 6222279082     | other         | accepted  |


    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.com | 2017-10-1  | 2018-01-31  | branding_fee | betald | none    | 2120000142     |


  Scenario: After login, Admin still sees new memberships on their landing page
    Given I am logged in as "admin@shf.se"
    When I am on the "landing" page
    Then I should see t("shf_applications.index.title")

  @selenium @time_adjust
  Scenario: After login, Member sees correct instructions
    Given the date is set to "2017-01-01"
    And I am logged in as "emma@mutts.com"
    When I am on the "user instructions" page
    Then I should not see "Alla inkomna ansökningar"
    And I should see "alla följer vår grafiska profil"
    And I should not see "kul att du är intresserad"

  Scenario: After login, User sees how to apply etc
    Given I am logged in as "fanny@mutts.com"
    When I am on the "user instructions" page
    Then I should not see t("info.logged_in_as_admin")
    And I should not see "alla följer vår grafiska profil"
    And I should see "Ansök om medlemsskap"

  Scenario: Visitor does not see instructions
    Given I am Logged out
    When I am on the "user instructions" page
    Then I should not see t("info.logged_in_as_admin")
    And I should not see "alla följer vår grafiska profil"
    And I should not see "Ansök om medlemsskap"

  @selenium @time_adjust
  Scenario: After login, Member sees correct instructions about member fee
    Given the date is set to "2018-03-01"
    And I am logged in as "emma@mutts.com"
    When I am on the "user instructions" page
    Then I should see "Ditt medlemskap har slutdatum"

  @selenium @time_adjust
  Scenario: After login, Member sees correct instructions about H branding
    Given the date is set to "2018-02-01"
    And I am logged in as "emma@mutts.com"
    When I am on the "user instructions" page
    Then I should see "Din H-märkningspremie har slutdatum"
    And I should not see "Ditt medlemskap har slutdatum"

  Scenario: After login, Member without previously paid H-branding sees correct instructions about H branding
    And I am logged in as "fanny@mutts.com"
    When I am on the "user instructions" page
    Then I should see "Din H-märkningspremie behöver betalas:"
    And I should not see "Ditt medlemskap har slutdatum"

  Scenario: After login, Member to be sees info about their app being handled
    Given I am logged in as "anna@muffs.com"
    When I am on the "user instructions" page
    Then I should see "Vi håller på att hantera din ansökan"
    And I should not see "Ditt medlemskap har slutdatum"