Feature: As an applicant
  In order to be able to edit my application
  I want to be allowed to do that

  PT: https://www.pivotaltracker.com/story/show/134078325


  Background:
    Given the following users exists
      | email                  | is_member | admin |
      | applicant_1@random.com | false     |       |
      | applicant_2@random.com | false     |       |
      | applicant_3@random.com | true      |       |
      | bob@barkybobs.com      | true      |       |
      | admin@shf.se           | true      | true  |

    And the following applications exist:
      | first_name | user_email             | company_number | status  |
      | Emma       | applicant_1@random.com | 5560360793     | Pending |
      | Hans       | applicant_2@random.com | 2120000142     | Pending |
      | Nils       | applicant_3@random.com | 2120000142     | Godkänd |
      | Bob        | bob@barkybobs.com      | 5560360793     | Avböjd  |

  Scenario: Applicant wants to edit his own application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "landing" page
    And I click on "Min ansökan"
    Then I should be on "Edit My Application" page
    And I fill in t("membership_applications.show.first_name") with "Anna"
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And I should be on the application page for "Anna"
    And I should see "Anna Lastname"

  Scenario: Applicant makes mistake when editing his own application
    Given I am logged in as "applicant_1@random.com"
    And I am on the "landing" page
    And I click on "Min ansökan"
    Then I should be on "Edit My Application" page
    And I fill in t("membership_applications.show.contact_email") with "sussimmi.nu"
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.error")
    And I should be on "Edit My Application" page

  Scenario: Applicant can not edit applications not created by him
    Given I am logged in as "applicant_1@random.com"
    And I navigate to the edit page for "Hans"
    Then I should see t("errors.not_permitted")

  Scenario: Applicant wants to view their own application
    Given I am logged in as "applicant_3@random.com"
    And I am on the "landing" page
    And I click on "Min ansökan"
    Then I should be on "Show My Application" page

  Scenario: Admin should be able to edit membership number
    Given I am logged in as "admin@shf.se"
    And I navigate to the edit page for "Nils"
    Then I should see t("membership_applications.show.membership_number")

  Scenario: Admin should be able to edit membership number when viewing site in English
    Given I am logged in as "admin@shf.se"
    And I navigate to the edit page for "Nils"
    Then I should see t("membership_applications.show.membership_number")


  Scenario: Admin can't edit membership number for a rejected application
    Given I am logged in as "admin@shf.se"
    And I navigate to the edit page for "Bob"
    Then I should not see t("membership_applications.show.membership_number")

