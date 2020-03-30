Feature: Admin edits a user account

  As an admin
  I need to be able to edit all of the user's account information.

  Background:

    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist
      | email                | password       | admin | member | first_name | last_name | membership_number |
      | admin@shf.se         | admin_password | true  | false  | emma       | admin     |                   |
      | member@shf.com       | password       | false | true   | mary       | member    |  9                 |
      | lars-member2@shf.com | password       | false | true   | Lars       | Member2   |                   |

    Given I am logged in as "admin@shf.se"


  @selenium
  Scenario: Admin edits membership number
    Given I am on the "edit user account" page for "member@shf.com"
    Then I should see "member@shf.com"
    And the t("activerecord.attributes.user.membership_number") field should be set to "9"
    And I fill in t("activerecord.attributes.user.membership_number") with "1010101"
    When I click on t("submit") button
    Then I should see t("admin_only.user_account.update.success")
    And I should see "mary Member"
    And I should see "1010101"
