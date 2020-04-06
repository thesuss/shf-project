Feature: User completes (or not) Membership Ethical Guidelines checklist

#  Background:
#    Given the App Configuration is not mocked and is seeded
#    And the Membership Ethical Guidelines Master Checklist exists
#
#    Given the following users exist:
#      | email                | admin | first_name | last_name | password       |
#      | new_user@example.com |       | NewUser1   | Lastname  | password       |
#      | admin@shf.se         | true  |            |           | admin_password |
#
#    And the application file upload options exist
#
#
#    And the following companies exist:
#      | name                 | company_number | email                  | region    |
#      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm |


#  @selenium
#  Scenario: User checks all guidelines - completes the list
#    Given I am logged in as "new_user@example.com"
#    And I am on the "user account" page for "new_user@example.com"
#    When I click on t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines") link
#    Then I should be on the "first unchecked membership guideline" page for "new_user@example.com"
#    And I should see "Medlemsåtagande" in the h1 title
#    And I should not see t("next")
#    When I check the box t("user_checklists.show_progress.read_and_agree_start")
#      When I check the checkbox with id "completed-checkbox"
#    And I wait for 5 seconds
#    Then I should see t("next")


#  Scenario: User checks only some of the guidelines


#  Scenario: User checks none of the guidelines
