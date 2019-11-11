Feature: As an admin
  So that I can help users that forgot their password (who can't reset it themselves via email)
  I need to be able to reset passwords for users


  Background:

    Given the following users exist:
      | email               | admin |
      | emma@happymutts.com |       |
      | bob@snarkybarky.se  |       |
      | admin@shf.se        | true  |

    And the following companies exist:
      | name        | company_number | email               |
      | Happy Mutts | 2120000142     | bowwow@bowsersy.com |

    And the following applications exist:
      | user_email          | company_number | state    |
      | emma@happymutts.com | 2120000142     | accepted |

    And I am logged in as "admin@shf.se"
    And I am on the "all users" page

  @selenium @member
  Scenario: A member needs their password reset
    Then I click the icon with CSS class "edit" for the row with "emma@happymutts.com"
    And I fill in t("activerecord.attributes.user.password") with "newpassword"
    And I fill in t("activerecord.attributes.user.password_confirmation") with "newpassword"
    Then I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("admin_only.user_profile.update.success")

  @selenium @user
  Scenario: A user needs their password reset
    Then I click the icon with CSS class "edit" for the row with "bob@snarkybarky.se"
    And I fill in t("activerecord.attributes.user.password") with "snarkywoofwoof"
    And I fill in t("activerecord.attributes.user.password_confirmation") with "snarkywoofwoof"
    Then I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("admin_only.user_profile.update.success")

  @selenium @user
  Scenario: New password and confirmation don't match [SAD PATH]
    Then I click the icon with CSS class "edit" for the row with "bob@snarkybarky.se"
    And I fill in t("activerecord.attributes.user.password") with "snarkywoofwoof"
    And I fill in t("activerecord.attributes.user.password_confirmation") with "not-a-match"
    Then I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("admin_only.user_profile.update.error")
    And I should see t("activerecord.errors.models.user.attributes.password_confirmation.confirmation")

  @selenium @user
  Scenario: New password is too short (not valid) [SAD PATH]
  Then I click the icon with CSS class "edit" for the row with "bob@snarkybarky.se"
  And I fill in t("activerecord.attributes.user.password") with "woof"
  And I fill in t("activerecord.attributes.user.password_confirmation") with "woof"
  Then I click on t("devise.registrations.edit.submit_button_label") button
  And I should see t("admin_only.user_profile.update.error")
  And I should see t("errors.messages.too_short", count: 6)

  @selenium @user
  Scenario: New password and confirmation don't match AND new one is too short [SAD PATH]
    Then I click the icon with CSS class "edit" for the row with "bob@snarkybarky.se"
    And I fill in t("activerecord.attributes.user.password") with "woof"
    And I fill in t("activerecord.attributes.user.password_confirmation") with "nomatch"
    Then I click on t("devise.registrations.edit.submit_button_label") button
    And I should see t("admin_only.user_profile.update.error")
    And I should see t("activerecord.errors.models.user.attributes.password_confirmation.confirmation")
    And I should see t("errors.messages.too_short", count: 6)
