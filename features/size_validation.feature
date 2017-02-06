Feature: As an applicant
  if I upload a too large file
  I need to get an understandable error-message
  PT: https://www.pivotaltracker.com/story/show/136316233

  Background:
    Given the following users exists
      | email                  | admin |
      | applicant_1@random.com |       |


  Scenario: Uploads too large file
    Given I am logged in as "applicant_1@random.com"
    And I am on the "submit new membership application" page
    When I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.last_name | membership_applications.new.company_number | membership_applications.new.phone_number | membership_applications.new.contact_email |
      | Hans                                   | Newfoundland                          | 5560360793                                 | 031-1234567                              | applicant_2@random.com                          |
    And I choose a file named "diploma_huge.pdf" to upload
    And I click on t("membership_applications.new.submit_button_label")
    Then I should see t("membership_applications.uploads.file_too_large", max_size: '5 MB')
    And I should not see t("membership_applications.create.success")


  Scenario: Uploads a file just under the limit
    Given I am logged in as "applicant_1@random.com"
    And I am on the "submit new membership application" page
    When I fill in the translated form with data:
      | membership_applications.new.first_name | membership_applications.new.last_name | membership_applications.new.company_number | membership_applications.new.phone_number | membership_applications.new.contact_email |
      | Hans                                   | Newfoundland                          | 5560360793                                 | 031-1234567                              | applicant_2@random.com                          |
    And I choose a file named "upload-just-under-limit.pdf" to upload
    And I click on t("membership_applications.new.submit_button_label")
    Then I should not see t("membership_applications.uploads.file_too_large", max_size: '5 MB')
    And I should see t("membership_applications.create.success")

