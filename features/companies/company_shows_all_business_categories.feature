Feature: Show business categories for a company to a visitor

  As a visitor
  So that I can see if a company offers skills/services that I want,
  I want to see the skills/services of all of the employees in the
  company on the company's info page

  The way to edit them is via each individual's profile page,
  since each individual had to submit documentation about their skills on
  the company page. (So they are _not_ editable on the company page by anyone.)


  PT https://www.pivotaltracker.com/story/show/135397241

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                  | admin | membership_status | member | agreed_to_membership_guidelines |
      | emma@happymutts.com    |       | current_member    | true   | true                            |
      | lars@happymutts.com    |       | current_member    | true   | true                            |
      | anna@happymutts.com    |       | current_member    | true   | true                            |
      | bowser@snarkybarky.se  |       | current_member    | true   | true                            |
      | overdue@snarkybarky.se |       | in_grace_period   | false  | true                            |
      | former@snarkybarky.se  |       | former_member     | false  | true                            |
      | admin@shf.se           | true  |                   |        |                                 |

    And the following companies exist:
      | name                 | company_number | email                  |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com |
      | HappyMutts           | 2120000142     | woof@happymutts.com    |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Awesome      |
      | Rehab        |
      | Agility      |
      | Blorf        |
      | Medic        |

    And the following applications exist:
      | user_email             | company_number | categories   | state    |
      | emma@happymutts.com    | 5562252998     | Groomer      | accepted |
      | lars@happymutts.com    | 5562252998     | Trainer      | accepted |
      | anna@happymutts.com    | 5562252998     | Psychologist | accepted |
      | bowser@snarkybarky.se  | 2120000142     | Agility      | accepted |
      | overdue@snarkybarky.se | 2120000142     | Medic        | accepted |
      | former@snarkybarky.se  | 2120000142     | Blorf        | accepted |

  # ===================================================================================

  Scenario: Categories of 3 current members all show for a company
    Given I am Logged out
    And I am the page for company number "5562252998"
    Then I should see "Groomer"
    And I should see "Trainer"
    And I should see "Psychologist"
    And I should not see "Rehab"
    And I should not see "Medic"
    And I should not see "Blorf"


  Scenario: Only categories of current members show for a company; not for in grace period or former members.
    Given I am Logged out
    And I am the page for company number "2120000142"
    Then I should see "Agility"
    And I should not see "Medic"
    And I should not see "Blorf"
