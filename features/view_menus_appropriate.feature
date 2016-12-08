Feature: As a user of the site
  So that I take advantage of the capabilities of the site
  And so that I do not see what I shouldn't have access to,
  Show me menus that are only appropriate for my role

  PT https://www.pivotaltracker.com/story/show/135306757


  Background:
    Given the following users exists
      | email              | admin | is_member |
      | hans@woof.se       |       | false     |
      | emma@happymutts.se |       | true      |
      | admin@shf.se       | true  | true      |


  Scenario: Visitor is viewing the site
    Given I am Logged out
    And I am on the "landing" page
    Then I should see the "home" menu item
    And I should see the "log in" menu item
    And I should not see the "log out" menu item
    And I should see the "brochure and info" menu item
    And I should not see the "member application" menu item
    And I should not see the "edit my application" menu item
    And I should not see the "edit my company" menu item
    And I should not see the "member only pages" menu item
    And I should not see the "admin" menu item

  Scenario: User (not a member) is viewing the site
    Given I am logged in as "hans@woof.se"
    And I am on the "landing" page
    Then I should see the "home" menu item
    And I should not see the "log in" menu item
    And I should see the "log out" menu item
    And I should see the "brochure and info" menu item
    And I should see the "member application" menu item
    And I should not see the "edit my application" menu item
    And I should not see the "edit my company" menu item
    And I should not see the "member only pages" menu item
    And I should not see the "admin" menu item

  Scenario: Member is viewing the site
    Given I am logged in as "emma@happymutts.se"
    And I am on the "landing" page
    Then I should see the "home" menu item
    And I should not see the "log in" menu item
    And I should see the "log out" menu item
    And I should see the "brochure and info" menu item
    And I should not see the "member application" menu item
    And I should see the "edit my application" menu item
    And I should see the "edit my company" menu item
    And I should see the "member only pages" menu item
    And I should not see the "admin" menu item


  Scenario: Admin is viewing the site
    Given I am logged in as "admin.shf.se"
    And I am on the "landing" page
    Then I should see the "home" menu item
    And I should not see the "log in" menu item
    And I should see the "log out" menu item
    And I should see the "brochure and info" menu item
    And I should not see the "member application" menu item
    And I should see the "edit my application" menu item
    And I should see the "edit my company" menu item
    And I should see the "member only pages" menu item
    And I should see the "admin" menu item

