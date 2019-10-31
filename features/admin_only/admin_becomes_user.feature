Feature: Admin becomes a user

  As an admin
  So that I can see exactly what a user sees and be able to act as them
  I need to be able to 'become' a user


  Background:

    Given the date is set to "2019-06-06"

    Given the App Configuration is not mocked and is seeded

    Given the following users exist
      | email          | password | admin | member | first_name | last_name | membership_number |
      | admin@shf.se   | password | true  |        | emma       | admin     |                   |
      | member@shf.com | password | false | true   | mary       | member    | 1001              |

    Given the following business categories exist
      | name  | description             |
      | rehab | physical rehabilitation |

    Given the following companies exist:
      | name       | company_number | email               | region    |
      | HappyMutts | 5562252998     | woof@happymutts.com | Stockholm |

    Given the following applications exist:
      | user_email     | company_number | categories | state    |
      | member@shf.com | 5562252998     | rehab      | accepted |


    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id |company_number|
      | member@shf.com | 2019-1-1   | 2019-12-31  | member_fee   | betald | none    |              |
      | member@shf.com | 2019-1-1   | 2019-12-31  | branding_fee | betald | none    | 5562252998     |


    And I am logged in as "admin@shf.se"
    And I am on the "all users" page


  @selenium
  Scenario: Admin becomes a user
    Given I should see "member@shf.com"
    And I click on "member@shf.com"
    And I should see "mary member"
    And I should see "member@shf.com"
    And I click on t("hello", name: 'emma')
    When I click on the t("admin_only.user_profile.edit.become_this_user") link
    Then I should see t("admin_only.user_profile.become.have_become", user_id: 2, user_name: 'mary member')
    And I should see "mary member"
    And I should see "member@shf.com"
