Feature: Membership expiration alerts are sent out (Condition response)

  As a nightly task
  So that users are notified ('alerted') about their upcoming membership expiration
  in time for them to plan for it
  Email members about their upcoming membership expiration every 60, 30, 14, and 2 days
  before their membership is going to expire


  Background:

    Given the following users exist:
      | email                            | admin | member |
      | member01_exp_jan_3@mutts.se      |       | true   |
      | member02_exp_jan_4@mutts.se      |       | true   |
      | member03_exp_jan_15@mutts.se     |       | true   |
      | member04_exp_jan_15@mutts.se     |       | true   |
      | member05_exp_jan_31@mutts.se     |       | true   |
      | member06_exp_jan_31@bowwowwow.se |       | true   |
      | member07_exp_jan_31@bowwowwow.se |       | true   |
      | member08_exp_mar_2@bowwowwow.se  |       | true   |
      | member09_exp_mar_2@bowwowwow.se  |       | true   |
      | member10_exp_mar_2@bowwowwow.se  |       | true   |
      | member11_exp_mar_2@bowwowwow.se  |       | true   |
      | member12_exp_mar_2@bowwowwow.se  |       | true   |
      | admin@shf.se                     | true  |        |

    Given the following business categories exist
      | name  | description             |
      | rehab | physical rehabilitation |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name        | company_number | email               | region    |
      | Bow Wow Wow | 2120000142     | hellow@bowwowwow.se | Stockholm |
      | Mutts R Us  | 5562252998     | voof@mutts.se       | Stockholm |

    And the following applications exist:
      | user_email                       | company_number | categories | state    |
      | member01_exp_jan_3@mutts.se      | 5562252998     | rehab      | accepted |
      | member02_exp_jan_4@mutts.se      | 5562252998     | rehab      | accepted |
      | member03_exp_jan_15@mutts.se     | 5562252998     | rehab      | accepted |
      | member04_exp_jan_15@mutts.se     | 5562252998     | rehab      | accepted |
      | member05_exp_jan_31@mutts.se     | 5562252998     | rehab      | accepted |
      | member06_exp_jan_31@bowwowwow.se | 2120000142     | rehab      | accepted |
      | member07_exp_jan_31@bowwowwow.se | 2120000142     | rehab      | accepted |
      | member08_exp_mar_2@bowwowwow.se  | 2120000142     | rehab      | accepted |
      | member09_exp_mar_2@bowwowwow.se  | 2120000142     | rehab      | accepted |
      | member10_exp_mar_2@bowwowwow.se  | 2120000142     | rehab      | accepted |
      | member11_exp_mar_2@bowwowwow.se  | 2120000142     | rehab      | accepted |
      | member12_exp_mar_2@bowwowwow.se  | 2120000142     | rehab      | accepted |


    And the following payments exist
      | user_email                       | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member01_exp_jan_3@mutts.se      | 2018-1-2   | 2019-1-3    | member_fee   | betald | none    |                |
      | member02_exp_jan_4@mutts.se      | 2018-1-3   | 2019-1-4    | member_fee   | betald | none    |                |
      | member03_exp_jan_15@mutts.se     | 2018-1-16  | 2019-1-15   | member_fee   | betald | none    |                |
      | member04_exp_jan_15@mutts.se     | 2018-1-16  | 2019-1-15   | member_fee   | betald | none    |                |
      | member05_exp_jan_31@mutts.se     | 2018-2-1   | 2019-1-31   | member_fee   | betald | none    |                |
      | member06_exp_jan_31@bowwowwow.se | 2018-2-1   | 2019-1-31   | member_fee   | betald | none    |                |
      | member07_exp_jan_31@bowwowwow.se | 2018-2-1   | 2019-1-31   | member_fee   | betald | none    |                |
      | member08_exp_mar_2@bowwowwow.se  | 2018-3-3   | 2019-3-2    | member_fee   | betald | none    |                |
      | member09_exp_mar_2@bowwowwow.se  | 2018-3-3   | 2019-3-2    | member_fee   | betald | none    |                |
      | member10_exp_mar_2@bowwowwow.se  | 2018-3-3   | 2019-3-2    | member_fee   | betald | none    |                |
      | member11_exp_mar_2@bowwowwow.se  | 2018-3-3   | 2019-3-2    | member_fee   | betald | none    |                |
      | member12_exp_mar_2@bowwowwow.se  | 2018-3-3   | 2019-3-2    | member_fee   | betald | none    |                |


  @condition
  Scenario: On Jan 1, Membership Expire Alerts condition is processed
    Given the date is set to "2019-01-01"
    And there is a condition with class_name "MembershipExpireAlert" and timing "before"
    And the condition has days set to [60, 30, 14, 2]
    And the process_condition task sends "condition_response" to the "MembershipExpireAlert" class
    Then the condition days includes 60
    And the condition days includes 30
    And the condition days includes 14
    And the condition days includes 2
    And "member01_exp_jan_3@mutts.se" should receive an email
    And "member03_exp_jan_15@mutts.se" should receive an email
    And "member04_exp_jan_15@mutts.se" should receive an email
    And "member05_exp_jan_31@mutts.se" should receive an email
    And "member06_exp_jan_31@bowwowwow.se" should receive an email
    And "member07_exp_jan_31@bowwowwow.se" should receive an email
    And "member08_exp_mar_2@bowwowwow.se" should receive an email
    And "member09_exp_mar_2@bowwowwow.se" should receive an email
    And "member10_exp_mar_2@bowwowwow.se" should receive an email
    And "member11_exp_mar_2@bowwowwow.se" should receive an email
    And "member12_exp_mar_2@bowwowwow.se" should receive an email

  @condition
  Scenario: On Jan 2, Membership Expire Alerts condition is processed
    Given the date is set to "2019-01-02"
    And there is a condition with class_name "MembershipExpireAlert" and timing "before"
    And the condition has days set to [60, 30, 14, 2]
    And the process_condition task sends "condition_response" to the "MembershipExpireAlert" class
    Then the condition days includes 60
    And the condition days includes 30
    And the condition days includes 14
    And the condition days includes 2
    And "member02_exp_jan_4@mutts.se" should receive an email

