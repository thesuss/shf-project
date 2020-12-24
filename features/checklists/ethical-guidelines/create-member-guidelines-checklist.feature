Feature:  SHF Member Guidelines checklist is created  when a user registers

  When a user registers
  the SHF Member Guidelines checklist should be created for the user
  so the user can read and agree and check-off each item in the checklist.

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    # ------------------------------------------------------------------------

  @selenium
  Scenario: User registers and sees the SHF Guidelines checklist
    Given I am on the "register as a new user" page
    And I fill in t("activerecord.attributes.user.first_name") with "New"
    And I fill in t("activerecord.attributes.user.last_name") with "User"
    And I fill in t("activerecord.attributes.user.email") with "new-user@example.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I fill in t("devise.registrations.new.confirm_password") with "password"
    When I click on t("devise.registrations.new.submit_button_label")

    Then I should see t("devise.registrations.new.success")
    And I should be on the "user account" page for "new-user@example.com"
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
