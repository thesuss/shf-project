Feature: Only members and admins can see members only (hidden) pages

  Background:

    Given the following users exists
      | email                    | admin | is_member |
      | not_a_member@bowsers.com |       | false     |
      | emma@happymutts.com      |       | true      |
      | admin@shf.se             | true  | true      |


  Scenario: Visitor cannot see members only pages
    Given I am on the "static workgroups" page
    Then I should see "Du har inte behörighet att göra detta."
    And I should not see "Arbetsgrupper"

  Scenario: Logged in user (not a member) cannot see members only pages
    Given I am on the "static workgroups" page
    Given I am logged in as "not_a_member@bowsers.com"
    Then I should see "Du har inte behörighet att göra detta."
    And I should not see "Arbetsgrupper"

  Scenario: Member can see members only pages
    Given I am logged in as "emma@happymutts.com"
    And  I am on the "static workgroups" page
    Then I should see "Arbetsgrupper"
    Then I should not see "Du har inte behörighet att göra detta."

  Scenario: Admin can see members only pages
    Given I am logged in as "emma@happymutts.com"
    And  I am on the "static workgroups" page
    Then I should see "Arbetsgrupper"
    Then I should not see "Du har inte behörighet att göra detta."

      
    