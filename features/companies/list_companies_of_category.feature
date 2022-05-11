Feature: Category page: list all companies in the category

  As any type of visitor
  In order to easily find a company of a certain category
  I should be able to see the companies of that category listed
  PT: https://www.pivotaltracker.com/story/show/135684057

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                     | admin | membership_status | member | agreed_to_membership_guidelines |
      | emma@nomoresnarkybarky.se |       | current_member    | true   | true                            |
      | ernt@woof.se              |       | current_member    | true   | true                            |
      | anna@hunds.se             |       | current_member    | true   | true                            |
      | in_grace_period@arf.se    |       | in_grace_period   | false  | true                            |
      | admin@shf.se              | true  |                   |        |                                 |

    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |
      | Norrbotten   |
      | Uppsala      |

    And the following kommuns exist:
      | name     |
      | Alingsås |
      | Bromölla |
      | Laxå     |
      | Dalarna  |

    And the following companies exist:
      | name                 | company_number | email                     | region       | kommun   |
      | No More Snarky Barky | 5562252998     | emma@nomoresnarkybarky.se | Stockholm    | Alingsås |
      | WOOF                 | 5569467466     | ernt@woof.se              | Västerbotten | Bromölla |
      | Hunds                | 2120000142     | anna@hunds.se             | Norrbotten   | Laxå     |
      | Arf!                 | 6536944389     | hello@arf.se              | Stockholm    | Alingsås |


    And the following business categories exist
      | name    |
      | Awesome |
      | Sadness |
      | Goodies |
      | Extra   |

    And the following applications exist:
      | user_email                | company_number | categories | state    |
      | emma@nomoresnarkybarky.se | 5562252998     | Awesome    | accepted |
      | ernt@woof.se              | 5569467466     | Awesome    | accepted |
      | anna@hunds.se             | 2120000142     | Sadness    | accepted |
      | in_grace_period@arf.se    | 6536944389     | Awesome    | accepted |

    And the following payments exist
      | user_email                | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@nomoresnarkybarky.se | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5562252998     |
      | emma@nomoresnarkybarky.se | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |
      | ernt@woof.se              | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5569467466     |
      | ernt@woof.se              | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |
      | anna@hunds.se             | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | anna@hunds.se             | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |                |

    And the following company addresses exist:
      | company_name         | region  | kommun  |
      | No More Snarky Barky | Uppsala | Dalarna |
      | Arf!                 | Uppsala | Dalarna |

    And the following memberships exist:
      | email                     | first_day  | last_day   |
      | emma@nomoresnarkybarky.se | 2017-01-01 | 2017-12-31 |
      | ernt@woof.se              | 2017-01-01 | 2017-12-31 |
      | anna@hunds.se             | 2017-01-01 | 2017-12-31 |
      | in_grace_period@arf.se    | 2016-9-02  | 2017-9-01  |


    Given the date is set to "2017-10-01"
 # -----------------------------------------------------------------------------------------------

  @time_adjust
  Scenario: Categories list multiple businesses
    Given I am Logged out
    And I am on the business category "Awesome"
    Then I should see "No More Snarky Barky"
    And I should see "Stockholm"
    And I should see "Uppsala"
    And I should see "Stockholm<br>Uppsala" or "Uppsala<br>Stockholm" in the raw HTML
    And I should see "WOOF"
    And I should see "Västerbotten"
    And I should not see "Hunds"

  @time_adjust
  Scenario: Categories list businesses
    Given I am Logged out
    And I am on the business category "Sadness"
    Then I should not see "No More Snarky Barky"
    And I should see "Hunds"
    And I should see "Norrbotten"
    When I am logged in as "anna@hunds.se"
    And I am on the business category "Sadness"
    Then I should not see "No More Snarky Barky"
    And I should see "Hunds"
    And I should see "Norrbotten"

  Scenario: Categories list no businesses
    Given I am Logged out
    And I am on the business category "Goodies"
    Then I should see t("business_categories.show.no_one_applied_category")
    And I should not see "No More Snarky Barky"
    And I should not see "Hunds"

  @selenium
  Scenario: Another category is added
    Given I am logged in as "admin@shf.se"
    And I am on the "edit application" page for "ernt@woof.se"
    And I select "Extra" Category
    And I click on t("shf_applications.edit.submit_button_label")
    When I am on the business category "Extra"
    Then I should see "WOOF"
    And I should see "Västerbotten"

  @selenium
  Scenario: Company with no current members is not shown
    Given I am logged out
    And I am on the business category "Awesome"
    Then I should see "No More Snarky Barky"
    And I should see "WOOF"
    And I should not see "Arf!"
