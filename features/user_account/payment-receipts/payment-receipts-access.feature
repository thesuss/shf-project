Feature: Access to the Payment Receipts pages (view, download)

  Background:
    Given the date is set to "2022-06-06"
    And the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                                      | admin | membership_number | membership_status | member | first_name | last_name               |
      | member-all-payments-successful@example.com |       | 101               | current_member    | true   | Member     | All-Payments-Successful |
      | some-other-member@example.com              |       | 102               | current_member    | true   | Member     | Some-Other-Member       |
      | some-user@example.com                      |       |                   | not_a_member      | false  | User       | Some-Userl              |
      | admin@shf.se                               | true  |                   |                   |        |            |                         |

    And the following users have agreed to the Membership Ethical Guidelines:
      | email                                      | agreed to date |
      | member-all-payments-successful@example.com |                |
      | some-other-member@example.com              |                |

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
      | user_email                                   | contact_email                                | company_number | state    | categories |
      | some-other-member@example.com                | lars-member@happymutts.com                   | 2120000142     | accepted | Grooming   |
      | member-all-payments-successful@example.com   | emma-member@bowsers.com                      | 2120000142     | accepted | Grooming   |
      | some-user@example.com                        | some-user@example.com                        | 2120000142     | accepted | Grooming   |

    And the following payments exist
      | user_email                                   | start_date | expire_date | payment_type | status       | hips_id | company_number |
      | member-all-payments-successful@example.com   | 2022-01-1  | 2022-12-31  | member_fee   | betald       | none    |                |
      | member-all-payments-successful@example.com   | 2022-01-1  | 2022-12-31  | branding_fee | betald       | none    | 2120000142     |
      | member-all-payments-successful@example.com   | 2021-01-1  | 2021-12-31  | member_fee   | betald       | none    |                |
      | member-all-payments-successful@example.com   | 2021-01-1  | 2021-12-31  | branding_fee | betald       | none    | 2120000142     |
      | some-other-member@example.com                | 2022-01-01 | 2022-12-31  | member_fee   | betald       | none    |                |
      | some-other-member@example.com                | 2021-01-01 | 2021-12-31  | member_fee   | betald       | none    |                |
      | some-other-member@example.com                | 2020-01-01 | 2020-12-31  | member_fee   | ofullständig | none    |                |


    And the following memberships exist
      | email                                        | membership_number | first_day | last_day   | notes |
      | member-all-payments-successful@example.com   | 101               | 2022-01-1 | 2022-12-31 |       |
      | some-other-member@example.com                | 102               | 2022-01-1 | 2022-12-31 |       |



    And these files have been uploaded:
      | user_email                                   | file name | description                               |
      | member-all-payments-successful@example.com   | image.png | Image of a class completion certification |
      | some-other-member@example.com                | image.png | Image of a class completion certification |

  # ==========================================================================================


  Scenario: Member can view own payment receipts
    Given I am logged in as "member-all-payments-successful@example.com"
    And I am on the "view payment receipts" page
    Then I should not see a message telling me I am not allowed to see that page

  Scenario: Member can download own payment receipts
    Given I am logged in as "member-all-payments-successful@example.com"
    And I am on the "download payment receipts" page
    Then I should not see a message telling me I am not allowed to see that page


  Scenario: Admin can view payment receipts for a member
    Given I am logged in as "admin@shf.se"
    And I am on the "view payment receipts" page for "member-all-payments-successful@example.com"
    Then I should not see a message telling me I am not allowed to see that page

  Scenario: Admin can download payment receipts for a member
    Given I am logged in as "admin@shf.se"
    And I am on the "download payment receipts" page for "member-all-payments-successful@example.com"
    Then I should not see a message telling me I am not allowed to see that page


  Scenario: A Member cannot view payment receipts for another member
    Given I am logged in as "some-other-member@example.com"
    And I am on the "view payment receipts" page for "member-all-payments-successful@example.com"
    Then I should see a message telling me I am not allowed to see that page

  Scenario: A Member cannot download payment receipts for another member
    Given I am logged in as "some-other-member@example.com"
    And I am on the "download payment receipts" page for "member-all-payments-successful@example.com"
    Then I should see a message telling me I am not allowed to see that page


  Scenario: A User cannot view payment receipts for a member
    Given I am logged in as "some-other-member@example.com"
    And I am on the "view payment receipts" page for "member-all-payments-successful@example.com"
    Then I should see a message telling me I am not allowed to see that page

  Scenario: A User cannot download payment receipts for a member
    Given I am logged in as "some-other-member@example.com"
    And I am on the "download payment receipts" page for "member-all-payments-successful@example.com"
    Then I should see a message telling me I am not allowed to see that page


  Scenario: A Visitor cannot view payment receipts for a member
    Given I am logged out
    And I am on the "view payment receipts" page for "member-all-payments-successful@example.com"
    Then I should see a message telling me I am not allowed to see that page

  Scenario: A Visitor cannot download payment receipts for a member
    Given I am logged out
    And I am on the "download payment receipts" page for "member-all-payments-successful@example.com"
    Then I should see a message telling me I am not allowed to see that page
