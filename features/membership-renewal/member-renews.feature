Feature: Member renews their membership

  As a member
  So that I can continue my membership for another term
  I must be able to renew


  Background:

    Given the date is set to "2019-06-06"
    Given the App Configuration is not mocked and is seeded
    And the Membership Ethical Guidelines Master Checklist exists

    And the date membership guidelines were required is 2018-11-01

    Given the following users exist:
      | email                                                         | admin | membership_status | membership_number | member | first_name   | last_name                                  |
      | member-all-reqs-met@example.com                               |       | current_member    | 101               | true   | Member       | All-Requirements-met                       |
      | member-in-grace-period-all-reqs-met@example.com               |       | current_member    | 102               | true   | LapsedMember | All-Requirements-met                       |
      | member-agreed-before-current-start@example.com                |       | current_member    | 103               | true   | Member       | Agreed-Before-Current-Start                |
      | member-agreed-on-current-start@example.com                    |       | current_member    | 104               | true   | Member       | Agreed-On-Current-Start                    |
      | member-agreed-after-current-start@example.com                 |       | current_member    | 105               | true   | Member       | Agreed-After-Current-Start                 |
      | member-agreed-before-guidelines_reqd@example.com              |       | current_member    | 106               | true   | Member       | Agreed-Before-Guidelines-Reqd              |
      | member-paid-another-in-advance@example.com                    |       | current_member    | 107               | true   | Member       | Paid-for-Another-In-Advance                |
      | member-paid-in-advance-1st-before-guidelines-reqd@example.com |       | current_member    | 108               | true   | Member       | Started-b4-guidelines-reqd Paid-in-advance |
      | admin@shf.se                                                  | true  |                   |                   |        |              |                                            |

    And the following regions exist:
      | name      |
      | Stockholm |

    And the following companies exist:
      | name    | company_number | email            | region    |
      | Bowsers | 2120000142     | bark@bowsers.com | Stockholm |

    And the following business categories exist
      | name     | description   |
      | Grooming | grooming dogs |

    And the following applications exist:
      | user_email                                                    | contact_email                                               | company_number | state    | categories |
      | member-all-reqs-met@example.com                               | emma-member@bowsers.com                                     | 2120000142     | accepted | Grooming   |
      | member-in-grace-period-all-reqs-met@example.com               | lars-member@bowsers.com                                     | 2120000142     | accepted | Grooming   |
      | member-agreed-before-current-start@example.com                | member-agreed-before@bowsers.com                            | 2120000142     | accepted | Grooming   |
      | member-agreed-before-guidelines_reqd@example.com              | member-agreed-before-guidelines-req@bowsers.com             | 2120000142     | accepted | Grooming   |
      | member-paid-another-in-advance@example.com                    | member-paid-another-in-advance@example.com                  | 2120000142     | accepted | Grooming   |
      | member-paid-in-advance-1st-before-guidelines-reqd@example.com | member-paid-in-advance-1st-before-renewals-done@bowsers.com | 2120000142     | accepted | Grooming   |


    And the following payments exist
      | user_email                                                    | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member-all-reqs-met@example.com                               | 2019-01-1  | 2019-12-31  | member_fee   | betald | none    |                |
      | member-all-reqs-met@example.com                               | 2019-01-1  | 2019-12-31  | branding_fee | betald | none    | 2120000142     |
      | member-in-grace-period-all-reqs-met@example.com               | 2019-01-1  | 2019-12-31  | member_fee   | betald | none    |                |
      | member-agreed-before-current-start@example.com                | 2019-01-1  | 2019-12-31  | member_fee   | betald | none    |                |
      | member-agreed-before-guidelines_reqd@example.com              | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |                |
      | member-paid-another-in-advance@example.com                    | 2019-01-1  | 2020-12-31  | member_fee   | betald | none    |                |
      | member-paid-in-advance-1st-before-guidelines-reqd@example.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |                |
      | member-paid-in-advance-1st-before-guidelines-reqd@example.com | 2019-01-1  | 2019-12-31  | member_fee   | betald | none    |                |


    And the following memberships exist:
      | email                                                         | first_day | last_day   |
      | member-all-reqs-met@example.com                               | 2019-01-1 | 2019-12-31 |
      | member-in-grace-period-all-reqs-met@example.com               | 2019-01-1 | 2019-12-31 |
      | member-agreed-before-current-start@example.com                | 2019-01-1 | 2019-12-31 |
      | member-agreed-before-guidelines_reqd@example.com              | 2018-01-1 | 2018-12-31 |
      | member-paid-another-in-advance@example.com                    | 2019-01-1 | 2019-12-31 |
      | member-paid-another-in-advance@example.com                    | 2020-01-1 | 2020-12-31 |
      | member-paid-in-advance-1st-before-guidelines-reqd@example.com | 2018-01-1 | 2018-12-31 |
      | member-paid-in-advance-1st-before-guidelines-reqd@example.com | 2019-01-1 | 2019-12-31 |


    And these files have been uploaded:
      | user_email                                                    | file name | description                               |
      | member-all-reqs-met@example.com                               | image.png | Image of a class completion certification |
      | member-in-grace-period-all-reqs-met@example.com               | image.png | Image of a class completion certification |
      | member-agreed-before-current-start@example.com                | image.png | Image of a class completion certification |
      | member-paid-another-in-advance@example.com                    | image.png | Image of a class completion certification |
      | member-paid-in-advance-1st-before-guidelines-reqd@example.com | image.png | Image of a class completion certification |


    And the following users have agreed to the Membership Ethical Guidelines:
      | email                                                         | date agreed to |
      | member-all-reqs-met@example.com                               | 2019-01-1      |
      | member-all-reqs-met@example.com                               | 2019-01-2      |
      | member-in-grace-period-all-reqs-met@example.com               | 2019-01-1      |
      | member-agreed-before-current-start@example.com                | 2018-12-31     |
      | member-agreed-before-current-start@example.com                | 2018-12-31     |
      | member-agreed-before-guidelines_reqd@example.com              | 2018-10-31     |
      | member-paid-another-in-advance@example.com                    | 2019-01-01     |
      | member-paid-in-advance-1st-before-guidelines-reqd@example.com | 2018-10-31     |

    # ---------------------------------------------------------------------------------------------


  Scenario Outline: Current member, all reqs met, renews on days on or before expiration
    Given the date is set to "<the_date>"
    And I am logged in as "member-all-reqs-met@example.com"
    And I am on the "user account" page
    Then I should see t("users.renewal.title_time_to_renew")
    And I should see t("users.renewal.instructions")
    And the link button t("users.show.pay_membership") should not be disabled
    When I click on t("users.show.pay_membership")
    And I complete the membership payment
    And the user is paid through "<new_paid_thru_date>"

    Scenarios:
      | the_date   | new_paid_thru_date |
      | 2019-12-30 | 2020-12-31         |
      | 2019-12-31 | 2020-12-31         |


  Scenario: Member in grace period, must agree to guidelines again and upload a file again
    Given the date is set to "2020-01-05"
    And I am logged in as "member-in-grace-period-all-reqs-met@example.com"
    And I am on the "user account" page
    Then I should see t("users.renewal.title_renewal_overdue")
    And I should see t("users.renewal.renewal_overdue_warning")

    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And I should see "0%"
    And I should see t("users.ethical_guidelines_link_or_checklist.in_grace_period.must_agree_again")
    And I should see t("users.uploaded_files_requirement.in_grace_period.must_upload_again")

    When I agree to all Membership Ethical Guidelines on 2020-01-05
    And I reload the page
    Then I should see t("users.ethical_guidelines_link_or_checklist.agreed_to", date: '2020-01-05')

    When I am on the "upload a new file" page
    Then I should see t("uploaded_files.new.upload_button_title")
    And I should see t("activerecord.attributes.uploaded_file.description")
    When I choose a file named "biff-image.png" to upload
    And I click on t("save")
    Then I should see t("uploaded_files.create.success", file_name: 'biff-image.png')

    When I am on the "user account" page
    And I reload the page
    Then I should see t("users.uploaded_files_requirement.in_grace_period.have_been_uploaded")
    And I should see "biff-image.png" in the list of uploaded files required for renewal
    And the link button t("users.show.pay_membership") should not be disabled

    When I click on t("users.show.pay_membership")
    And I complete the membership payment
    Then the user is paid through "2021-01-04"


  Scenario: Current member, last agreed to guidelines 1 day before start of current membership term
    Given the date is set to "2019-12-05"
    And I am logged in as "member-agreed-before-current-start@example.com"
    And I am on the "user account" page
    Then I should see t("users.renewal.title_time_to_renew")
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And the link button t("users.show.pay_membership") should be disabled

    # Agree to the guidelines
    When I agree to all Membership Ethical Guidelines on 2019-12-05
    And I am on the "user account" page
    Then the link button t("users.show.pay_membership") should not be disabled

    When I click on t("users.show.pay_membership")
    And I complete the membership payment
    Then the user is paid through "2020-12-31"


  Scenario: Agreed to Ethical Guidelines before the date that renewals were fully implemented, after membership started
    Given the date is set to "2018-12-01"
    And I am logged in as "member-agreed-before-guidelines_reqd@example.com"

    # upload a file so it is uploaded during the current membership period
    When I am on the "upload a new file" page
    Then I should see t("uploaded_files.new.upload_button_title")
    And I should see t("activerecord.attributes.uploaded_file.description")
    When I choose a file named "biff-image.png" to upload
    And I click on t("save")
    Then I should see t("uploaded_files.create.success", file_name: 'biff-image.png')

    When I am on the "user account" page
    Then I should see t("users.renewal.title_time_to_renew")
    And I should see "biff-image.png" in the list of uploaded files required for renewal

    And the link button t("users.show.pay_membership") should not be disabled
    When I click on t("users.show.pay_membership")
    And I complete the membership payment
    Then the user is paid through "2019-12-31"


  Scenario: Paid in advance for this and the next membership. Agreed to guidelines before first membership
    # today is last day of first membership. No renewal needed
    Given the date is set to "2019-12-01"
    And I am logged in as "member-paid-another-in-advance@example.com"
    And I am on the "user account" page
    Then I should not see t("users.renewal.title_time_to_renew")

    # today is last day of last membership need to renew and agree to new terms. must 'log in' to get updated membership status
    Given the date is set to "2020-12-01"
    And I am logged in as "member-paid-another-in-advance@example.com"
    And I am on the "user account" page

    Then I should see t("users.renewal.title_time_to_renew")
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And I should see t("users.uploaded_files_requirement.need_to_upload")
    And the link button t("users.show.pay_membership") should be disabled

    # Agree to guidelines and upload a file
    Given I agree to all Membership Ethical Guidelines on 2020-12-01

    # upload a file so it is uploaded during the current membership period
    When I am on the "upload a new file" page
    Then I should see t("uploaded_files.new.upload_button_title")
    And I should see t("activerecord.attributes.uploaded_file.description")
    When I choose a file named "biff-image.png" to upload
    And I click on t("save")
    Then I should see t("uploaded_files.create.success", file_name: 'biff-image.png')

    When I am on the "user account" page
    Then I should see "biff-image.png" in the list of uploaded files required for renewal

    And the link button t("users.show.pay_membership") should not be disabled

    When I click on t("users.show.pay_membership")
    And I complete the membership payment
    Then the user is paid through "2021-12-31"


  Scenario: Paid in advance for this and the next membership. Agreed to guidelines before first membership and uploaded a file during 2nd membership
    # Upload a file during 2nd membership
    Given the date is set to "2020-06-06"
    And I am logged in as "member-paid-another-in-advance@example.com"
    And I am on the "upload a new file" page
    Then I should see t("uploaded_files.new.upload_button_title")
    And I should see t("activerecord.attributes.uploaded_file.description")
    When I choose a file named "biff-image.png" to upload
    And I click on t("save")
    Then I should see t("uploaded_files.create.success", file_name: 'biff-image.png')
    And I am logged out

    Given the date is set to "2020-12-06"
    And I am logged in as "member-paid-another-in-advance@example.com"
    And I am on the "user account" page
    Then I should see t("users.renewal.title_time_to_renew")
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And I should see t(""users.uploaded_files_requirement.current_member.have_been_uploaded")
    And I should see "biff-image.png" in the list of uploaded files required for renewal

    # Agree to the guidelines
    Given I agree to all Membership Ethical Guidelines on 2020-12-06
    And I am logged out

    Given the date is set to "2020-12-06"
    And I am logged in as "member-paid-another-in-advance@example.com"
    And I am on the "user account" page
    Then the link button t("users.show.pay_membership") should not be disabled

    When I click on t("users.show.pay_membership")
    And I complete the membership payment
    Then the user is paid through "2021-12-31"


  Scenario: Paid in advance for this and the next membership. Agreed to guidelines after first membership, before renewals fully implemented, and uploaded a file during 2nd membership
    Given the date is set to "2018-12-06"
    And I am logged in as "member-paid-in-advance-1st-before-guidelines-reqd@example.com"
    And I am on the "user account" page
    Then I should not see t("users.renewal.title_time_to_renew")
    And I am logged out

    Given the date is set to "2019-12-06"
    And I am logged in as "member-paid-in-advance-1st-before-guidelines-reqd@example.com"
    And I am on the "user account" page
    Then I should see t("users.renewal.title_time_to_renew")
    And I should see t("users.ethical_guidelines_link_or_checklist.agree_to_guidelines")
    And I should see t(""users.uploaded_files_requirement.current_member.have_been_uploaded")
    And I should see "image.png" in the list of uploaded files required for renewal


    When I agree to all Membership Ethical Guidelines on 2020-12-06
    And I am on the "user account" page
    Then the link button t("users.show.pay_membership") should not be disabled

    When I click on t("users.show.pay_membership")
    And I complete the membership payment
    Then the user is paid through "2020-12-31"
