Feature: As a Member
  So that I can get the correct information
  Landing page should show correct information

  PT: https://www.pivotaltracker.com/story/show/135683887

  Background:
    Given the following users exist
      | email           | admin | member | membership_number |
      | anna@muffs.com  |       | false  |                   |
      | fanny@mutts.com |       | false  |                   |
      | emma@mutts.com  |       | true   | 1001              |
      | admin@shf.se    | true  | false  |                   |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |

    Given the following companies exist:
      | name       | company_number | email                 | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com   | Stockholm |
      | HappyMuffs | 2120022142     | woof@happymutts.com   | Stockholm |

    Given the following applications exist:
      | user_email     | company_number | category_name | state    |
      | emma@mutts.com | 2120000142     | rehab         | accepted |
      | anna@muffs.com | 2120022142     | other         | pending  |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.com | 2017-10-1  | 2017-12-31  | branding_fee | betald | none    | 2120000142     |


  Scenario: After login, Admin still sees new memberships on their landing page
    Given I am logged in as "admin@shf.se"
    When I am on the "landing" page
    Then I should see t("shf_applications.index.title")

  @selenium @time_adjust
  Scenario: After login, Member sees instructions about applying for membership
    Given the date is set to "2018-01-01"
    And I am logged in as "emma@mutts.com"
    When I am on the "landing" page
    Then I should not see "Alla inkomna ansökningar"
    And I should see t(".member.using_the_logo")
    And I should not see t('.user.how_to_apply')

  Scenario: After login, User sees instructions about using their badge, etc
    Given I am logged in as "fanny@mutts.com"
    When I am on the "landing" page
    Then I should not see t("info.logged_in_as_admin")
    And I should not see t(".member.using_the_logo")
    And I should see t('.user.how_to_apply')

  Scenario: Visitor does not see instructions
    Given I am Logged out
    When I am on the "landing" page
    Then I should not see t("info.logged_in_as_admin")
    And I should not see t(".member.using_the_logo")
    And I should not see t('.user.how_to_apply')
