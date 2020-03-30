Feature:  Create the SHF Member Guidelines checklist for a user when a user registers
#
#When an admin approves an application for an applicant,
#the SHF Member Guidelines checklist should be created for the applicant
#so the applicant can read and agree and check-off each item in the checklist.
#
#
#  Background:
#
#    Given the following users exist:
#      | email                   | admin | member | first_name | last_name |
#      | applicant@happymutts.se |       |        | Kicki      | Applicant |
#      | admin@shf.se            | yes   |        |            |           |
#
#
#    Given the following Master Checklist exist:
#      | name                  | displayed_text               | list position | parent name    |
#      | SHF Member Guidelines | SHF Member Guidelines        |               |                |
#      | Section 1             | guideline section 1          | 0             | SHF Guidelines |
#      | Guideline 1.1         | description of guideline 1.1 | 0             | Section 1      |
#      | Guideline 1.2         | description of guideline 1.2 | 1             | Section 1      |
#      | Guideline 1.3         | description of guideline 1.3 | 2             | Section 1      |
#      | Section 2             | guideline section 1          | 1             | SHF Guidelines |
#      | Guideline 2.1         | description of guideline 2.1 | 0             | Section 2      |
#
#
#    Given the following regions exist:
#      | name      |
#      | Stockholm |
#
#    Given the following companies exist:
#      | name        | company_number | email               | region    |
#      | Happy Mutts | 5560360793     | hello@happymutts.se | Stockholm |
#
#    Given the following business categories exist
#      | name     | description                     |
#      | grooming | grooming dogs from head to tail |
#
#    And the application file upload options exist
#
#    And the following applications exist:
#      | user_email              | company_number | categories | state        |
#      | applicant@happymutts.se | 5560360793     | grooming   | under_review |
#
#    # ------------------------------------------------------------------------
#
#  @selenium
#  Scenario: Agree to SHF Guidelines checklist is created when an application is approved
#    # Ensure the applicant does not have the Guidelines checklist yet
#    Given I am logged in as "applicant@happymutts.se"
#    And I am on the "my checklists" page
#    Then I should not see the checklist "SHF Member Guidelines" in the list of user checklists
#    And I am logged out
#
#    # Admin approves the application.  This should create the Guidelines checklist
#    Given I am logged in as "admin@shf.se"
#    And I am on the "application" page for "applicant@happymutts.se"
#    When I click on t("shf_applications.accept_btn")
#    And I should be on the "edit application" page for "applicant@happymutts.se"
#    And I should see t("shf_applications.accept.success")
#    And I click on t("shf_applications.edit.submit_button_label")
#    And I should see t("shf_applications.update.success_with_app_files_missing")
#    And I should see t("shf_applications.accepted")
#
#    And I am on the "checklists" page for "applicant@happymutts.se"
#    Then I should see the checklist "SHF Member Guidelines" in the list of user checklists
#
#    And I am logged out
#
#    # Now the Guidelines checklist should be there
#    And I am logged in as "applicant@happymutts.se"
#    And I am on the "my checklists" page
#    Then I should see the checklist "SHF Member Guidelines" in the list of user checklists
#
