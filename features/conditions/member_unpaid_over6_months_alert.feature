Feature: Membership address get emails when a member has been unpaid for > 6 months

  As a nightly task,
  so that admins can check to see if lapsed members are still using the H-markt image but shouldn't be,
  assuming that anyone that still hasn't paid after 6 months is not going to pay for membership,
  Send an email to the membership address (not the admins!) with all members that are unpaid for 6 months.

  Timing for the task can be any valid Timing (e.g. every day, on a day of the month, etc.)


  Background:

    Given the following users exists
      | email                          | admin | member |
      | exp_jun_1_01@mutts.se          |       | true   |
      | exp_jun_1_02@mutts.se          |       | true   |
      | exp_jun_2_01@mutts.se          |       | true   |
      | exp_jun_12_01@mutts.se         |       | true   |
      | not_a_member_new_app@mutts.se  |       | false  |
      | not_a_member_rejected@mutts.se |       | false  |
      | admin_1@shf.se                 | true  |        |
      | admin_2@shf.se                 | true  |        |

    Given the following business categories exist
      | name  | description             |
      | rehab | physical rehabilitation |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name       | company_number | email         | region    |
      | Mutts R Us | 5562252998     | voof@mutts.se | Stockholm |

    
    And the following applications exist:
      | user_email                     | company_number | categories | state    |
      | exp_jun_1_01@mutts.se          | 5562252998     | rehab      | accepted |
      | exp_jun_1_02@mutts.se          | 5562252998     | rehab      | accepted |
      | exp_jun_2_01@mutts.se          | 5562252998     | rehab      | accepted |
      | exp_jun_12_01@mutts.se         | 5562252998     | rehab      | accepted |
      | not_a_member_new_app@mutts.se  | 5562252998     | rehab      | new      |
      | not_a_member_rejected@mutts.se | 5562252998     | rehab      | rejected |


    And the following payments exist
      | user_email             | start_date | expire_date | payment_type | status | hips_id | company_number |
      | exp_jun_1_01@mutts.se  | 2017-07-02 | 2018-07-01  | member_fee   | betald | none    |                |
      | exp_jun_1_02@mutts.se  | 2017-07-02 | 2018-07-01  | member_fee   | betald | none    |                |
      | exp_jun_2_01@mutts.se  | 2017-07-03 | 2018-07-02  | member_fee   | betald | none    |                |
      | exp_jun_12_01@mutts.se | 2017-07-13 | 2018-07-12  | member_fee   | betald | none    |                |


  @condition
  Scenario Outline: Timing is every day: members checked every day and alert sent if needed
    Given there is a condition with class_name "MemberUnpaidOver6MonthsAlert" and timing "every_day"
    And the date is set to <today>
    And the process_condition task sends "condition_response" to the "MemberUnpaidOver6MonthsAlert" class
    Then "medlem@sverigeshundforetagare.se" should receive <medlem_email> email
    And "admin_1@shf.se" should receive no email
    And "admin_2@shf.se" should receive no email
    And "exp_jun_1_01@mutts.se" should receive no email
    And "exp_jun_1_02@mutts.se" should receive no email
    And "exp_jun_2_01@mutts.se" should receive no email
    And "exp_jun_12_01@mutts.se" should receive no email
    And "not_a_member_new_app@mutts.se" should receive no email
    And "not_a_member_rejected@mutts.se" should receive no email

    Scenarios:
      | today        | medlem_email |
      | "2018-12-31" | no           |
      | "2019-1-01"  | no           |
      | "2019-1-02"  | an           |
      | "2019-1-03"  | an           |
      | "2019-1-11"  | an           |
      | "2019-1-12"  | an           |
      | "2019-1-13"  | an           |


  @condition
  Scenario Outline: Timing set to 12th of the month; alert only runs on the 12th
    Given there is a condition with class_name "MemberUnpaidOver6MonthsAlert" and timing "day_of_month"
    And the condition has the month day set to 12
    And the date is set to <today>
    And the process_condition task sends "condition_response" to the "MemberUnpaidOver6MonthsAlert" class
    Then "medlem@sverigeshundforetagare.se" should receive <medlem_email> email
    And "admin_1@shf.se" should receive no email
    And "admin_2@shf.se" should receive no email
    And "exp_jun_1_01@mutts.se" should receive no email
    And "exp_jun_1_02@mutts.se" should receive no email
    And "exp_jun_2_01@mutts.se" should receive no email
    And "exp_jun_12_01@mutts.se" should receive no email
    And "not_a_member_new_app@mutts.se" should receive no email
    And "not_a_member_rejected@mutts.se" should receive no email

    Scenarios:
      | today        | medlem_email |
      | "2018-12-31" | no           |
      | "2019-1-01"  | no           |
      | "2019-1-02"  | no           |
      | "2019-1-03"  | no           |
      | "2019-1-11"  | no           |
      | "2019-1-12"  | an           |
      | "2019-1-13"  | no           |
