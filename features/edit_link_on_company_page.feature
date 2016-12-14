Feature: As the owner of a company (or an admin)
  As I am on the company
  I should easily be able to edit it

  Background:

    Given the following users exists
      | email                 | admin | is_member |
      | emma@happymutts.com   |       | true      |
      | lars@happymutts.com   |       | true      |
      | anna@happymutts.com   |       | true      |
      | bowser@snarkybarky.se |       | true      |
      | admin@shf.se          | true  | false     |

    And the following companies exist:
      | name                 | company_number | email                  |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com |
      | HappyMutts           | 2120000142     | woof@happymutts.com    |

    And the following applications exist:
      | first_name | user_email            | company_number | status  |
      | Emma       | emma@happymutts.com   | 5562252998     | Godkänd |
      | Lars       | lars@happymutts.com   | 5562252998     | Godkänd |
      | Anna       | anna@happymutts.com   | 5562252998     | Godkänd |
      | Bowser     | bowser@snarkybarky.se | 2120000142     | Godkänd |


  Scenario: Visitor does not see edit link for a company
    Given I am Logged out
    And I am the page for company number "5562252998"
    Then I should see "Företagets e-postadress:"
    And I should not see "Redigera detta företag"

  Scenario: Admin does see edit link for company
    Given I am logged in as "admin@shf.se"
    And I am the page for company number "5562252998"
    Then I should see "Företagets e-postadress:"
    And I should see "Redigera detta företag"

  Scenario: Other user does not see edit link for a company
    Given I am logged in as "bowser@snarkybarky.se"
    And I am the page for company number "5562252998"
    Then I should see "Företagets e-postadress:"
    And I should not see "Redigera detta företag"

  Scenario: User related to company does see edit link for company
    Given I am logged in as "emma@happymutts.com"
    And I am the page for company number "5562252998"
    Then I should see "Företagets e-postadress:"
    And I should see "Redigera detta företag"
