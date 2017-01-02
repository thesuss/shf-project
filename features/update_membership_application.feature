Feature: As an Admin
  In order to get members into SHF and get their money
  I need to be able to accept/reject their application
  PT: https://www.pivotaltracker.com/story/show/133950603

  Background:
    Given the following users exists
      | email                                  | admin |
      | applicant_1@random.com                 |       |
      | applicant_2@random.com                 |       |
      | emma_under_review@happymutts.se        |       |
      | hans_under_review@happymutts.se        |       |
      | anna_waiting_for_info@nosnarkybarky.se |       |
      | nils_member@bowwowwow.se               |       |
      | lars_rejected@snarkybark.se            |       |
      | admin@shf.se                           | true  |

    Given the following business categories exist
      | name         | description                     |
      | dog grooming | grooming dogs from head to tail |
      | dog crooning | crooning to dogs                |
      | rehab        | physcial rehabitation           |


    Given the following companies exist:
      | name                 | company_number | email                 |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.se |


    And the following applications exist:
      | first_name      | user_email                             | company_number | category_name | state                 |
      | EmmaUnderReview | emma_under_review@happymutts.se        | 5562252998     | rehab         | under_review          |
      | HansUnderReview | hans_under_review@happymutts.se        | 5562252998     | dog grooming  | under_review          |
      | AnnaWaiting     | anna_waiting_for_info@nosnarkybarky.se | 5560360793     | rehab         | waiting_for_applicant |
      | LarsRejected    | lars_rejected@snarkybark.se            | 0000000000     | rehab         | rejected              |
      | NilsAccepted    | nils_member@bowwowwow.se               | 0000000000     | dog crooning  | accepted              |

    And I am logged in as "admin@shf.se"
    And time is frozen at 2016-12-16


  Scenario: Application submitter can see but not update the Application status
    Given I am Logged out
    And I am logged in as "emma_under_review@happymutts.se"
    Given I am on "EmmaUnderReview" application page
    And I should see status line with status t("membership_applications.under_review")
    And I should not see button t("membership_applications.accept")
    And I should not see button t("membership_applications.reject")


  Scenario: Admin rejects an application (under_review to rejected)
    Given I am on "EmmaUnderReview" application page
    When I click on t("membership_applications.reject")
    Then I should see t("membership_applications.reject.success")
    And I should see status line with status t("membership_applications.rejected")
    And I should not see t("membership_applications.update.enter_member_number")
    When I am on the "landing" page
    Then I should see 2 t("membership_applications.rejected")
    And I should see 1 t("membership_applications.under_review")
    And I should see 1 t("membership_applications.waiting_for_applicant")
    And I should see 1 t("membership_applications.accepted")


  Scenario: Admin rejects an application that had uploaded files (under_review to rejected)
    Given  I am logged in as "emma_under_review@happymutts.se"
    And I am on the "edit my application" page
    And I choose a file named "diploma.pdf" to upload
    And I click on t("membership_applications.edit.submit_button_label")
    And I am on the "edit my application" page
    And I choose a file named "image.png" to upload
    And I click on t("membership_applications.edit.submit_button_label")
    And I am Logged out
    And I am logged in as "admin@shf.se"
    And I am on "EmmaUnderReview" application page
    When I click on t("membership_applications.reject")
    Then I should see t("membership_applications.reject.success")
    And I should see status line with status t("membership_applications.rejected")
    And I should see 0 uploaded files listed
    And I should not see "diploma.pdf"
    And I should not see "image.png"


  Scenario: Things go wrong when trying to reject an application


  Scenario: Anna edits her application to provide needed info (from waiting for applicant to under_review)
    Given I am logged in as "anna_waiting_for_info@nosnarkybarky.se"
    And I am on the "edit my application" page
    And I fill in t("membership_applications.show.last_name") with "ForInfo"
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And I should see status line with status t("membership_applications.under_review")
    And I am Logged out
    And I am logged in as "admin@shf.se"
    And I am on "AnnaWaiting" application page
    Then I should see status line with status t("membership_applications.under_review")
    And I am on the "landing" page
    And I should see 1 t("membership_applications.accepted")
    And I should see 3 t("membership_applications.under_review")
    And I should see 1 t("membership_applications.rejected")


  # From under_review to...
  Scenario: Admin requests more info from user (from under_review to need info)
    Given I am on "EmmaUnderReview" application page
    When I click on t("membership_applications.ask_applicant_for_info")
    Then I should see t("membership_applications.need_info.success")
    And I should see status line with status t("membership_applications.waiting_for_applicant")
    And I should not see t("membership_applications.update.enter_member_number")
    When I am on the "landing" page
    Then I should see 2 t("membership_applications.waiting_for_applicant")
    And I should see 1 t("membership_applications.under_review")
    And I should see 1 t("membership_applications.accepted")
    And I should see 1 t("membership_applications.rejected")

  Scenario: Admin cannot request more info from Member (since they are already approved)
    Given I am on "NilsAccepted" application page
    Then I should not see button t("membership_applications.accept")
    And I should not see button t("membership_applications.ask_applicant_for_info")
    And I should not see button t("membership_applications.cancel_waiting_for_applicant")


  Scenario: Admin changed from under_review to accepted
    Given I am on "EmmaUnderReview" application page
    When I click on t("membership_applications.accept")
    Then I should see t("membership_applications.accept.success")
    And I should see t("membership_applications.update.enter_member_number")
    When I am on the "landing" page
    Then I should see 1 t("membership_applications.waiting_for_applicant")
    And I should see 1 t("membership_applications.under_review")
    And I should see 2 t("membership_applications.accepted")
    And I should see 1 t("membership_applications.rejected")


  Scenario: Admin changed from under_review to rejected
    Given I am on "EmmaUnderReview" application page
    When I click on t("membership_applications.reject")
    Then I should see t("membership_applications.reject.success")
    And I should see status line with status t("membership_applications.rejected")
    And I should not see t("membership_applications.update.enter_member_number")
    When I am on the "landing" page
    Then I should see 1 t("membership_applications.waiting_for_applicant")
    And I should see 1 t("membership_applications.under_review")
    And I should see 2 t("membership_applications.rejected")
    And I should see 1 t("membership_applications.accepted")


  Scenario: Admin cannot change from under_review to 'cancel waiting for applicant'
    Given I am on "EmmaUnderReview" application page
    Then I should not see button t("membership_applications.cancel_waiting_for_applicant")


  # From waiting for applicant to...
  Scenario: Admin changed from 'waiting for applicant' to 'cancelled waiting for info'
    Given I am on "AnnaWaiting" application page
    When I click on t("membership_applications.cancel_waiting_for_applicant")
    Then I should see t("membership_applications.cancel_need_info.success")
    And I should see status line with status t("membership_applications.under_review")
    And I should not see t("membership_applications.waiting_for_applicant")
    And I should not see t("membership_applications.update.enter_member_number")
    When I am on the "landing" page
    And I should see 3 t("membership_applications.under_review")
    And I should not see t("membership_applications.waiting_for_applicant")
    And I should see 1 t("membership_applications.accepted")
    And I should see 1 t("membership_applications.rejected")


  Scenario: Admin cannot change from 'waiting for applicant' to rejected
    Given I am on "AnnaWaiting" application page
    When I click on t("membership_applications.reject")
    Then I should see t("membership_applications.reject.success")
    And I should see status line with status t("membership_applications.rejected")
    And I should not see t("membership_applications.waiting_for_applicant")
    And I should not see t("membership_applications.update.enter_member_number")
    When I am on the "landing" page
    And I should see 2 t("membership_applications.under_review")
    And I should not see t("membership_applications.waiting_for_applicant")
    And I should see 1 t("membership_applications.accepted")
    And I should see 2 t("membership_applications.rejected")


  Scenario: Admin cannot change from needs info to accepted
    Given I am on "AnnaWaiting" application page
    Then I should not see button t("membership_applications.waiting_for_applicant")


  Scenario: Admin cannot change from needs info to needs info
    Given I am on "AnnaWaiting" application page
    Then I should not see button t("membership_applications.waiting_for_applicant")


  Scenario: Needs info is not changed if admin edits the application
    Given I am on "AnnaWaiting" application page
    And I click on t("membership_applications.edit_membership_application")
    And I fill in t("membership_applications.show.last_name") with "AdminUpdated"
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And I should see status line with status t("membership_applications.waiting_for_applicant")
    And I should not see status line with status t("membership_applications.under_review")


  # From accepted to...
  Scenario: Admin changed from accepted to rejected
    Given I am on "NilsAccepted" application page
    When I click on t("membership_applications.reject")
    Then I should see t("membership_applications.reject.success")
    And I should see status line with status t("membership_applications.rejected")
    When I am on the "landing" page
    And I should see 2 t("membership_applications.under_review")
    And I should see 1 t("membership_applications.waiting_for_applicant")
    And I should see 0 t("membership_applications.accepted")
    And I should see 2 t("membership_applications.rejected")


  Scenario: Admin cannot change from accepted to accepted
    Given I am on "NilsAccepted" application page
    Then I should not see button t("membership_applications.accept")


  Scenario: Admin cannot change from accepted to needs info
    Given I am on "NilsAccepted" application page
    Then I should not see button t("membership_applications.waiting_for_applicant")


  Scenario: Admin cannot change from accepted to cancel needs info
    Given I am on "NilsAccepted" application page
    Then I should not see button t("membership_applications.cancel_waiting_for_applicant")


  # From rejected to...
  Scenario: User updates info = changed from rejected to under_review
    Given I am logged in as "lars_rejected@snarkybark.se"
    And I am on the "edit my application" page
    And I fill in t("membership_applications.show.last_name") with "BadBadLars"
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And I should see status line with status t("membership_applications.under_review")
    And I am Logged out
    And I am logged in as "admin@shf.se"
    And I am on "LarsRejected" application page
    Then I should see status line with status t("membership_applications.under_review")
    And I am on the "landing" page
    And I should see 3 t("membership_applications.under_review")
    And I should see 1 t("membership_applications.waiting_for_applicant")
    And I should see 1 t("membership_applications.accepted")
    And I should see 0 t("membership_applications.rejected")


  Scenario: Admin updates info thus it does not change from rejected to under_review
    Given I am on "LarsRejected" application page
    When I click on t("membership_applications.edit_membership_application")
    And I fill in t("membership_applications.show.last_name") with "BadBadLars"
    And I click on t("membership_applications.edit.submit_button_label")
    Then I should see t("membership_applications.update.success")
    And I should see status line with status t("membership_applications.rejected")
    When I am on the "landing" page
    And I should see 2 t("membership_applications.under_review")
    And I should see 1 t("membership_applications.waiting_for_applicant")
    And I should see 1 t("membership_applications.accepted")
    And I should see 1 t("membership_applications.rejected")


  Scenario: Admin cannot change from rejected to needs info
    Given I am on "LarsRejected" application page
    Then I should not see button t("membership_applications.waiting_for_applicant")


  Scenario: Admin cannot change from rejected to accepted
    Given I am on "LarsRejected" application page
    When I click on t("membership_applications.accept")
    Then I should see t("membership_applications.accept.success")
    And I should see t("membership_applications.update.enter_member_number")
    When I am on the "landing" page
    Then I should see 1 t("membership_applications.waiting_for_applicant")
    And I should see 2 t("membership_applications.under_review")
    And I should see 2 t("membership_applications.accepted")
    And I should see 0 t("membership_applications.rejected")


  Scenario: Admin cannot change from rejected to rejected
    Given I am on "LarsRejected" application page
    Then I should not see button t("membership_applications.reject")


  Scenario: Admin cannot change from rejected to cancel needs info
    Given I am on "LarsRejected" application page
    Then I should not see button t("membership_applications.cancel_waiting_for_applicant")
