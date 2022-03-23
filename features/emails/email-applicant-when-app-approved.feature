Feature: Applicant gets an email when the application is approved

  As an applicant,
  So that I know that SHF has approved the application (still need to pay)
  and so I know what I should expect to happen next,
  I should get an email letting me know the application was approved and now I need to pay
  And I should see a link to my account in the email so I can pay


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email              | admin |
      | emma@happymutts.se |       |
      | admin@shf.com      | true  |


    And the following business categories exist
      | name    |
      | Groomer |

    And the application file upload options exist

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name        | company_number | email              | region    |
      | Happy Mutts | 5562252998     | voof@happymutts.se | Stockholm |

    And the following applications exist:
      | user_email         | company_number | categories | state        |
      | emma@happymutts.se | 5562252998     | Groomer    | under_review |

    And the Membership Ethical Guidelines Master Checklist exists



  @selenium
  Scenario: Admin approves application and email is sent to applicant
    Given I am logged in as "admin@shf.com"
    And I am on the "application" page for "emma@happymutts.se"
    When I click on t("shf_applications.accept_btn")
    And I should be on the "edit application" page for "emma@happymutts.se"
    And I should see t("shf_applications.accept.success")
    And I click on t("shf_applications.edit.submit_button_label")

    And I should see t("shf_applications.update.success_with_app_files_missing")

    And I should see t("shf_applications.accepted")
    Then "emma@happymutts.se" should receive an email
    And I am logged in as "emma@happymutts.se"
    And I have agreed to all of the Membership Guidelines
    And I open the email
    And I should see t("mailers.shf_application_mailer.app_approved.subject") in the email subject
    # must make sure this is not the edit page; it would also match the pattern for the show user page
    And I should not see "http://localhost:3000/anvandare/1/redigera" in the email body
    And I should see "http://localhost:3000/anvandare/1" in the email body
    And I should see ""Sveriges Hundföretagare" <from@example.org>" in the email "from" header
    And I should see ""Sveriges Hundföretagare" <reply@example.org>" in the email "reply-to" header
    When I follow "http://localhost:3000/anvandare/1" in the email
    Then I should be on the "user account" page
