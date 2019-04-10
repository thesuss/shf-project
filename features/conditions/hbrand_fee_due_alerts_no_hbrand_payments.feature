Feature: Alerts sent for H-branding fee needs to be paid; company has NO previous H-Branding fee payments (a Condition response)

  As a nightly task
  So that users are notified ('alerted') if payment for the H-branding fee
  needs to be paid for a company they are associated with,
  alert them of this by sending an email to them.

  (reminder: "current member" = approved AND paid membership fee)

  See the comments in HBrandingFeeDueAlert:

  If today is August 6, 2019, an alert will only go out if the
  Condition configuration [:days] includes 400. ( Date.new(2019, 8, 6) - Date.new(2018, 7,2) = 400 )


  Background:

    Given the following users exists
      | email                         | admin | member |
      | member01_start_jan_4@mutts.se |       | true   |
      | member02_start_jan_5@mutts.se |       | true   |
      | member03_exp_jan_4@mutts.se   |       | false  |
      | member04_exp_jan_4@mutts.se   |       | false  |
      | member06_start_jan_17@voof.se |       | true   |
      | member07_start_jan_18@voof.se |       | true   |
      | admin@shf.se                  | true  |        |

    Given the following business categories exist
      | name  | description             |
      | rehab | physical rehabilitation |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name              | company_number | email         | region    |
      | Voof Unpaid       | 2120000142     | hello@voof.se | Stockholm |
      | Mutts R Us Unpaid | 5562252998     | voof@mutts.se | Stockholm |


    # Note that 2 are not members: member_03... and member04...
    And the following applications exist:
      | user_email                    | company_number | categories | state    |
      | member01_start_jan_4@mutts.se | 5562252998     | rehab      | accepted |
      | member02_start_jan_5@mutts.se | 5562252998     | rehab      | accepted |
      | member03_exp_jan_4@mutts.se   | 5562252998     | rehab      | new      |
      | member04_exp_jan_4@mutts.se   | 5562252998     | rehab      | rejected |
      | member06_start_jan_17@voof.se | 2120000142     | rehab      | accepted |
      | member07_start_jan_18@voof.se | 2120000142     | rehab      | accepted |


    And the following payments exist
      | user_email                    | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member01_start_jan_4@mutts.se | 2018-1-4   | 2019-1-3    | member_fee   | betald | none    |                |
      | member02_start_jan_5@mutts.se | 2018-1-5   | 2019-1-4    | member_fee   | betald | none    |                |
      | member06_start_jan_17@voof.se | 2018-1-17  | 2019-1-16   | member_fee   | betald | none    |                |
      | member07_start_jan_18@voof.se | 2018-1-18  | 2019-1-17   | member_fee   | betald | none    |                |

    Given there is a condition with class_name "HBrandingFeeDueAlert" and timing "after"
    Given the condition has days set to [1, 32, 42, 60, 363 ]

  @condition
  Scenario Outline: Emails sent when H-Brand Fee Due condition is processed (No H-Brand fees have been paid)
    Given the date is set to <today>
    And the process_condition task sends "condition_response" to the "HBrandingFeeDueAlert" class
    Then "member01_start_jan_4@mutts.se" should receive <member01_email> email
    And "member02_start_jan_5@mutts.se" should receive <memb02_email> email
    And "member06_start_jan_17@voof.se" should receive <memb06_email> email
    And "member07_start_jan_18@voof.se" should receive <memb07_email> email

    # mutts.se members will get emails based on 2018-01-04 until member01_start_jan_4 membership expires
    # voof.se  members will get emails based on 2018-01-17 until member06_start_jan_17 membership expires
    Scenarios:
      | today       | member01_email | memb02_email | memb06_email | memb07_email |
      | "2018-1-04" | no             | no           | no           | no           |
      | "2018-1-05" | an             | an           | no           | no           |
      | "2018-2-04" | no             | no           | no           | no           |
      | "2018-2-05" | an             | an           | no           | no           |
      | "2018-2-06" | no             | no           | no           | no           |
      | "2018-2-15" | an             | an           | no           | no           |
      | "2018-2-16" | no             | no           | no           | no           |
      | "2018-3-05" | an             | an           | no           | no           |
      | "2018-3-06" | no             | no           | no           | no           |
      | "2018-1-17" | no             | no           | no           | no           |
      | "2018-1-18" | no             | no           | an           | an           |
      | "2018-1-19" | no             | no           | no           | no           |
      | "2018-2-18" | no             | no           | an           | an           |
      | "2018-2-19" | no             | no           | no           | no           |
      | "2018-2-28" | no             | no           | an           | an           |
      | "2018-3-01" | no             | no           | no           | no           |
      | "2018-3-18" | no             | no           | an           | an           |
      | "2018-3-19" | no             | no           | no           | no           |
      | "2019-1-15" | no             | no           | an           | an           |

  @condition
  Scenario Outline: The earliest membership paid expires; the due date changes (No H-Brand fees have been paid)
    Given the date is set to <today>
    And the process_condition task sends "condition_response" to the "HBrandingFeeDueAlert" class
    Then "member01_start_jan_4@mutts.se" should receive <member01_email> email
    And "member02_start_jan_5@mutts.se" should receive <memb02_email> email
    And "member06_start_jan_17@voof.se" should receive <memb06_email> email
    And "member07_start_jan_18@voof.se" should receive <memb07_email> email

        # jan 2  = day 363 for mutts.se based on member01_start_jan_4
        # jan 3  = day 363 for mutts.se based on member02_start_jan_5
        # jan 15 = day 363 for voof.se based on member06_start_jan_17
        # jan 16 = day 363 for voof.se based on member07_start_jan_18
    Scenarios:
      | today       | member01_email | memb02_email | memb06_email | memb07_email |
      | "2019-1-02" | an             | an           | no           | no           |
      | "2019-1-03" | no             | an           | no           | no           |
      | "2019-1-04" | no             | no           | no           | no           |
      | "2019-1-15" | no             | no           | an           | an           |
      | "2019-1-16" | no             | no           | no           | an           |
      | "2019-1-17" | no             | no           | no           | no           |
