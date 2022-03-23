Feature: Seed business categories

  As an Admin
  So that members can choose the right categories for my business,
  And so that I don't have to enter them all by hand,
  I expect to see business categories when the system is revised (when it's seeded).

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                | admin |
      | admin@shf.com        | true  |

    And I am logged in as "admin@shf.com"

  @db_seeding
  Scenario: 11 business categories are created when it's initially seeded
    Given There are no "BusinessCategories" records in the db
    When the system is seeded with initial data
    And I am on the "business categories" page
    Then I should see t("business_categories.index.title")
    And I should see 11 "business_category" rows

  @db_seeding
  Scenario: only 11 business categories are ever created, even if it's seeded multiple times
    Given There are no "BusinessCategories" records in the db
    When the system is seeded with initial data
    And I am on the "business categories" page
    Then I should see 11 "business_category" rows

