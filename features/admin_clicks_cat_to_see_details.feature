@admin @parallel_group1
Feature: Link categories to categories show for an Admin
  As an admin
  In order to see every company that is using the business category
  I need to see all the companies using the business category when I click on the category

  PT: https://www.pivotaltracker.com/n/projects/1904891/stories/164983459

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists
    And the App Configuration is not mocked and is seeded

    Given the date is set to "2017-06-06"

    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following kommuns exist:
      | name     |
      | Alingsås |
      | Bromölla |

    Given the following companies exist:
      | name          | company_number | email          | region       | kommun   | city      | visibility     |
      | Groomer1      | 5560360793     | cmpy1@mail.com | Stockholm    | Alingsås | Harplinge | street_address |
      | kingGroomer   | 2120000142     | cmpy2@mail.com | Västerbotten | Bromölla | Harplinge | street_address |
      | GroomerNext   | 6613265393     | cmpy3@mail.com | Stockholm    | Alingsås | Harplinge | post_code      |
      | Company4      | 6222279082     | cmpy4@mail.com | Stockholm    | Alingsås | Harplinge | city           |
      | Company5      | 8025085252     | cmpy5@mail.com | Stockholm    | Alingsås | Harplinge | kommun         |
      | PsycGroomerCo | 6914762726     | cmpy6@mail.com | Stockholm    | Alingsås | Harplinge | none           |
      | Company7      | 7661057765     | cmpy7@mail.com | Stockholm    | Alingsås | Harplinge | street_address |
      | stockholmCo   | 7736362901     | cmpy8@mail.com | Stockholm    | Alingsås | Harplinge | street_address |

    And the following users exist:
      | email           | admin | member | membership_status |
      | user1@mutts.com |       | true   | current_member    |
      | user2@mutts.com |       | true   | current_member    |
      | user3@mutts.com |       | true   | current_member    |
      | user4@mutts.com |       | true   | current_member    |
      | user5@mutts.com |       | true   | current_member    |
      | admin@shf.se    | true  | false  |                   |


    And the following business categories exist
      | name         |
      | Grooming     |
      | Psychologist |
      | Trainer      |
      | Rehab        |
      | Walker       |
      | JustForFun   |

    And the following applications exist:
      | user_email      | company_number | categories               | state    |
      | user1@mutts.com | 5560360793     | Grooming, JustForFun     | accepted |
      | user2@mutts.com | 2120000142     | Grooming, Trainer, Rehab | accepted |
      | user3@mutts.com | 6914762726     | Psychologist, Grooming   | accepted |
      | user4@mutts.com | 6613265393     | Grooming                 | accepted |
      | user5@mutts.com | 2120000142     | Psychologist             | accepted |

    Given these files have been uploaded:
      | user_email      | file name | description                               |
      | user1@mutts.com | image.png | Image of a class completion certification |
      | user2@mutts.com | image.png | Image of a class completion certification |
      | user3@mutts.com | image.png | Image of a class completion certification |
      | user4@mutts.com | image.png | Image of a class completion certification |
      | user5@mutts.com | image.png | Image of a class completion certification |

    And the following users have agreed to the Membership Ethical Guidelines:
      | email           | date agreed to |
      | user1@mutts.com |                |
      | user2@mutts.com |                |
      | user3@mutts.com |                |
      | user4@mutts.com |                |
      | user5@mutts.com |                |


    And the following payments exist
      | user_email      | start_date | expire_date | payment_type | status | hips_id | company_number |
      | user1@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |
      | user2@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |
      | user3@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |
      | user4@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |
      | user5@mutts.com | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |
      | admin@shf.se    | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | admin@shf.se    | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | admin@shf.se    | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6613265393     |
      | admin@shf.se    | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6222279082     |
      | admin@shf.se    | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8025085252     |
      | user3@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6914762726     |
      | admin@shf.se    | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7661057765     |
      | admin@shf.se    | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7736362901     |


    And the following memberships exist:
      | email           | first_day  | last_day   |
      | user1@mutts.com | 2017-01-01 | 2017-12-31 |
      | user2@mutts.com | 2017-01-01 | 2017-12-31 |
      | user3@mutts.com | 2017-01-01 | 2017-12-31 |
      | user4@mutts.com | 2017-01-01 | 2017-12-31 |
      | user5@mutts.com | 2017-01-01 | 2017-12-31 |


  # ===========================================================================================

  @selenium
  Scenario: Show company details to admin
    Given I am logged in as "admin@shf.se"
    And I am the page for company number "6914762726"
    Then I should see "Grooming" link
    And I should see "Psychologist" link

    When I click on "Grooming"
    Then I should see "Grooming"
    And I should see "PsycGroomerCo"
    And I should see "GroomerNext"
    And I should see "kingGroomer"
    And I should see "Groomer1"
    And I should not see "stockholmCo"
    And I should not see "Company7"
    And I should not see "Company4"
    And I should not see "Company5"

  @selenium
  Scenario: Do not display company categories as links to a member
    Given I am logged in as "user1@mutts.com"
    And I am the page for company number "6914762726"
    Then I should not see "Grooming" link

  @selenium
  Scenario: Do not display company categories as links to a visitor
    Given I am logged out
    And I am the page for company number "6914762726"
    Then I should not see "Grooming" link

