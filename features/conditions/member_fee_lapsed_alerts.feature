Feature: Alerts for members whose membership has lapsed (a Condition response)

  As a nightly task
  So that users are notified ('alerted') their membership has lapsed
  Email members about their overdue fee
  after their membership has expired.


  Background:

    Given the following users exists
      | email                       | admin | member |
      | member01_exp_jan_3@mutts.se |       | true   |
      | member02_exp_jan_4@mutts.se |       | true   |
      | member03_new_app@mutts.se   |       | false  |
      | member04_rejected@mutts.se  |       | false  |
      | member06_exp_jan_16@voof.se |       | true   |
      | member07_exp_jan_17@voof.se |       | true   |
      | admin@shf.se                | true  |        |

    Given the following business categories exist
      | name  | description             |
      | rehab | physical rehabilitation |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name        | company_number | email         | region    |
      | Voof Unpaid | 2120000142     | hello@voof.se | Stockholm |
      | Mutts R Us  | 5562252998     | voof@mutts.se | Stockholm |


    # Note that 2 are not members: member_03... and member04...
    And the following applications exist:
      | user_email                  | company_number | categories | state    |
      | member01_exp_jan_3@mutts.se | 5562252998     | rehab      | accepted |
      | member02_exp_jan_4@mutts.se | 5562252998     | rehab      | accepted |
      | member03_new_app@mutts.se   | 5562252998     | rehab      | new      |
      | member04_rejected@mutts.se  | 5562252998     | rehab      | rejected |
      | member06_exp_jan_16@voof.se | 2120000142     | rehab      | accepted |
      | member07_exp_jan_17@voof.se | 2120000142     | rehab      | accepted |


    # Everyone in company "happymutts.se" is paid: the H-branding fee is paid
    And the following payments exist
      | user_email                  | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member01_exp_jan_3@mutts.se | 2018-1-4   | 2019-1-3    | member_fee   | betald | none    |                |
      | member02_exp_jan_4@mutts.se | 2018-1-5   | 2019-1-4    | member_fee   | betald | none    |                |
      | member06_exp_jan_16@voof.se | 2018-1-17  | 2019-1-16   | member_fee   | betald | none    |                |
      | member07_exp_jan_17@voof.se | 2018-1-18  | 2019-1-17   | member_fee   | betald | none    |                |

    Given there is a condition with class_name "MembershipLapsedAlert" and timing "after"
    Given the condition has days set to [1, 32, 363 ]

  @condition
  Scenario Outline: Membership lapsed alert sent
    Given the date is set to <today>
    And the process_condition task sends "condition_response" to the "MembershipLapsedAlert" class
    Then "member01_exp_jan_3@mutts.se" should receive <member01_email> email
    And "member02_exp_jan_4@mutts.se" should receive <memb02_email> email
    And "member06_exp_jan_16@voof.se" should receive <memb06_email> email
    And "member07_exp_jan_17@voof.se" should receive <memb07_email> email
    And "member03_new_app@mutts.se " should receive no email
    And "member04_rejected_app@mutts.se " should receive no email

    Scenarios:
      | today       | member01_email | memb02_email | memb06_email | memb07_email |
      | "2019-1-04" | an             | no           | no           | no           |
      | "2019-1-05" | no             | an           | no           | no           |
      | "2019-1-16" | no             | no           | no           | no           |
      | "2019-1-17" | no             | no           | an           | no           |
      | "2019-1-18" | no             | no           | no           | an           |
      | "2019-2-3"  | no             | no           | no           | no           |
      | "2019-2-4"  | an             | no           | no           | no           |
      | "2019-2-5"  | no             | an           | no           | no           |
      | "2019-2-17" | no             | no           | an           | no           |
      | "2019-2-18" | no             | no           | no           | an           |
      | "2020-1-1"  | an             | no           | no           | no           |
      | "2020-1-2"  | no             | an           | no           | no           |
      | "2020-1-14" | no             | no           | an           | no           |
      | "2020-1-15" | no             | no           | no           | an           |
