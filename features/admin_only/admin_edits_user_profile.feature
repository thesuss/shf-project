Feature: Admin edits user profile
  As an admin
  I want to be able to edit a user's profile information
  Including name, emails, membership number and password

  Background:
    Given the following users exist
      | email          | password | admin | member | first_name | last_name |
      | admin@shf.se   | password | true  | false  | emma       | admin     |
      | member@shf.com | password | false | true   | mary       | member    |

  @selenium
  Scenario: Admin edits user profile
    Given I am logged in as "admin@shf.se"
    And I am on the "all users" page
    And I should see "member@shf.com"
    Then I click the icon with CSS class "edit" for the row with "member@shf.com"
    And I should see t("admin_only.user_profile.edit.title", user: 'mary member')

    And I fill in t("activerecord.attributes.user.last_name") with ""
    And I fill in t("activerecord.attributes.user.email") with ""

    Then I click on t("devise.registrations.edit.submit_button_label") button

    And I should see t("admin_only.user_profile.update.error")

    And I fill in t("activerecord.attributes.user.first_name") with "Mary"
    And I fill in t("activerecord.attributes.user.last_name") with "Member"
    And I fill in t("activerecord.attributes.user.email") with "mary@newmail.com"
    And I fill in t("activerecord.attributes.user.membership_number") with "123"
    And I fill in t("activerecord.attributes.user.password") with "newpassword"
    And I fill in t("activerecord.attributes.user.password_confirmation") with "newpassword"

    Then I click on t("devise.registrations.edit.submit_button_label") button

    And I should see t("admin_only.user_profile.update.success")

    And I should see t("admin_only.user_profile.edit.title", user: 'Mary Member')
    And the t("activerecord.attributes.user.first_name") field should be set to "Mary"
    And the t("activerecord.attributes.user.last_name") field should be set to "Member"
    And the t("activerecord.attributes.user.membership_number") field should be set to "123"
