Feature: Edit a member page

  As an admin
  I want to be able to maintain content in a member page

  Background:

    Given the following users exists
      | email                    | admin | is_member |
      | admin@shf.se             | true  | true      |

  Scenario: Admin can edit contents of member page
    Given I am logged in as "admin@shf.se"
    And I am on the test member page
    And I click on t("shf_documents.edit_shf_document_contents")
    And I fill in "contents" with "This is content in the member pages testfile."
    And I click on t("submit")
    And I should see "This is content in the member pages testfile."
