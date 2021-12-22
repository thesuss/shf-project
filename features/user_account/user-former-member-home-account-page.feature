Feature: Former Member home (account) page - version 1.0

  As a former member,
  So that I can apply again
  I should be shown a message that I should contact the membership chairperson.


  Background:

    Given the date is set to "2018-01-01"
    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                     | admin | membership_status | membership_number | member | first_name | last_name |
      | former-member@example.com |       | former_member      | 1001              | true   | Former     | Member    |
      | admin@shf.se              | true  |                   |                   |        |            |           |

    And the following users have agreed to the Membership Ethical Guidelines:
      | email                     |
      | former-member@example.com |

    And the following regions exist:
      | name      |
      | Stockholm |

    And the following companies exist:
      | name    | company_number | email            | region    |
      | Bowsers | 2120000142     | bark@bowsers.com | Stockholm |


    And the following business categories exist
      | name     | description   |
      | Grooming | grooming dogs |


    And the following applications exist:
      | user_email                | contact_email             | company_number | state    | categories |
      | former-member@example.com | former-member@bowsers.com | 2120000142     | accepted | Grooming   |


    And the following payments exist
      | user_email                | start_date | expire_date | payment_type | status | hips_id | company_number |
      | former-member@example.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |                |
      | former-member@example.com | 2018-01-1  | 2018-12-31  | branding_fee | betald | none    | 2120000142     |


    And the following memberships exist
      | email                     | first_day | last_day   | notes |
      | former-member@example.com | 2018-01-1 | 2018-12-31 |       |

    And the following users have agreed to the Membership Ethical Guidelines:
      | email                     | date agreed to |
      | former-member@example.com | 2017-12-31     |


    Given the date is set to "2021-07-07"
    And the membership chair email is "membership-chair@shf.se"

  # ---------------------------------------------------------------------------------------------

  Scenario: Former member sees welcome message, message to contact the membership chair
    Given I am logged in as "former-member@example.com"
    And I am on the "user account" page for "former-member@example.com"
    Then I am a former member

    And I should see t("users.show_for_former_member.title")
    And I should see t("users.show_for_former_member.welcome")
    And I should see t("users.show_for_former_member.contact_membership", membership_email: 'membership-chair@shf.se')
