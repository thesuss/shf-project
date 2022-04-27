Feature: Member views their payment receipts as HTML on a page

  Background:
    Given the date is set to "2022-06-06"
    And the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                                        | admin | membership_number | membership_status | member | first_name | last_name                 |
      | member-all-payments-successful@example.com   |       | 101               | current_member    | true   | Member     | All-Payments-Successful   |
      | member-some-payments-successful@example.com  |       | 102               | current_member    | true   | Member     | Some-Payments-Successful  |
      | member-all-payments-unsuccessful@example.com |       | 103               | current_member    | true   | Member     | All-Payments-UNsuccessful |
      | member-no-payments@example.com               |       | 201               | in_grace_period   | true   | Member     | No-Payments               |
      | admin@shf.se                                 | true  |                   |                   |        |            |                           |

    And the following users have agreed to the Membership Ethical Guidelines:
      | email                                        | agreed to date |
      | member-all-payments-successful@example.com   |                |
      | member-some-payments-successful@example.com  |                |
      | member-all-payments-unsuccessful@example.com |                |
      | member-no-payments@example.com               |                |

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
      | member-some-payments-successful@example.com  | lars-member@happymutts.com                   | 2120000142     | accepted | Grooming   |
      | member-all-payments-successful@example.com   | emma-member@bowsers.com                      | 2120000142     | accepted | Grooming   |
      | member-all-payments-unsuccessful@example.com | member-all-payments-unsuccessful@example.com | 2120000142     | accepted | Grooming   |
      | member-no-payments@example.com               | member-no-payments@example.com               | 2120000142     | accepted | Grooming   |


    And the following memberships exist
      | email                                        | membership_number | first_day | last_day   | notes |
      | member-all-payments-successful@example.com   | 101               | 2022-01-1 | 2022-12-31 |       |
      | member-some-payments-successful@example.com  | 102               | 2022-01-1 | 2022-12-31 |       |
      | member-all-payments-unsuccessful@example.com | 103               | 2022-01-1 | 2022-12-31 |       |
      | member-no-payments@example.com               | 201               | 2022-01-1 | 2022-12-31 |       |

    And these files have been uploaded:
      | user_email                                   | file name | description                               |
      | member-all-payments-successful@example.com   | image.png | Image of a class completion certification |
      | member-some-payments-successful@example.com  | image.png | Image of a class completion certification |
      | member-all-payments-unsuccessful@example.com | image.png | Image of a class completion certification |
      | member-no-payments@example.com               | image.png | Image of a class completion certification |

    And the following payments exist
      | user_email                                   | start_date | expire_date | payment_type | status       | klarna_id           | company_number |
      | member-all-payments-successful@example.com   | 2022-01-1  | 2022-12-31  | member_fee   | betald       | klarna-1            |                |
      | member-all-payments-successful@example.com   | 2022-01-1  | 2022-12-31  | branding_fee | betald       | klarna-2            | 2120000142     |
      | member-all-payments-successful@example.com   | 2021-01-1  | 2021-12-31  | member_fee   | betald       | klarna-3            |                |
      | member-all-payments-successful@example.com   | 2021-01-1  | 2021-12-31  | branding_fee | betald       | klarna-4            | 2120000142     |
      | member-some-payments-successful@example.com  | 2022-01-01 | 2022-12-31  | member_fee   | betald       | klarna-5            |                |
      | member-some-payments-successful@example.com  | 2021-01-01 | 2021-12-31  | member_fee   | betald       | klarna-6            |                |
      | member-some-payments-successful@example.com  | 2020-01-01 | 2020-12-31  | member_fee   | ofullständig | klarna-unsuccessful |                |
      | member-all-payments-unsuccessful@example.com | 2022-01-1  | 2022-12-31  | member_fee   | ofullständig | klarna-7            |                |

  # ==========================================================================================

  Scenario: Member has successful payments and can see them
    Given I am logged in as "member-all-payments-successful@example.com"
    And I am on the "user account" page
    Then I should see t("payor.payment_receipts_buttons.view.button_title") link

    When I click on t("payor.payment_receipts_buttons.view.button_title") link
    Then I should see t("users.view_payment_receipts.title", name: 'Member All-Payments-Successful') in the h1 title
    And I should be on the "view payment receipts" page
    And I should see "klarna-1"
    And I should see "klarna-2"
    And I should see "klarna-3"
    And I should see "klarna-4"


  Scenario: Member has at least one unsuccessful payment; it is not displayed
    Given I am logged in as "member-some-payments-successful@example.com"
    And I am on the "user account" page
    Then I should see t("payor.payment_receipts_buttons.view.button_title") link

    When I click on t("payor.payment_receipts_buttons.view.button_title") link
    Then I should see t("users.view_payment_receipts.title", name: 'Member Some-Payments-Successful') in the h1 title
    And I should be on the "view payment receipts" page
    And I should see "klarna-5"
    And I should see "klarna-6"
    And I should not see "klarna-unsuccessful"


  Scenario: Member has all UNsuccessful payments; sees message that there is nothing to display
    # This shouldn't really happen:  cannot be a member if you haven't paid any fees
    Given I am logged in as "member-all-payments-unsuccessful@example.com"
    And I am on the "user account" page
    Then I should see t("users.show_for_member.no_payments")
    And I should not see t("payor.payment_receipts_buttons.view.button_title")


  Scenario: Member has no payments so there is no view payment receipts button
    # This shouldn't really happen:  cannot be a member if you haven't paid any fees
    Given I am logged in as "member-no-payments@example.com"
    And I am on the "user account" page
    Then I should see t("users.show_for_member.no_payments")
    And I should not see t("payor.payment_receipts_buttons.view.button_title")
