Feature: Alerts for all members in a company with H-branding fee PAST DUE are sent out (a Condition response)

  As a nightly task
  So that users are notified ('alerted') if payment for the H-branding fee
  is not paid for a company they are associated with.
  Send out an email to them.

  (reminder: "current member" = approved AND paid membership fee)

  Ex:
  member 1 membership exp = Jan 1
  member 2 membership exp = Jan 2

  no H-branding fee has ever been paid

  ===>  day 0 for h-branding fee = the earliest membership start (paid) date
        of the _current members_ of the company

  the first 'H-Branding fee is past due' email will go out on Jan. 2  ( = 1 day past due)


  Background:

    Given the following users exists
      | email                            | admin | member |
      | member01_exp_jan_3@mutts.se      |       | true   |
      | member02_exp_jan_4@mutts.se      |       | true   |
      | member03_exp_jan_4@mutts.se      |       | false  |
      | member04_exp_jan_4@mutts.se      |       | false  |
      | member06_exp_jan_15@voof.se      |       | true   |
      | member07_exp_jan_16@voof.se      |       | true   |
      | member20_exp_mar_2@happymutts.se |       | true   |
      | member21_exp_mar_2@happymutts.se |       | true   |
      | admin@shf.se                     | true  |        |

    Given the following business categories exist
      | name  | description             |
      | rehab | physical rehabilitation |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name              | company_number | email               | region    |
      | Voof Unpaid       | 2120000142     | hello@voof.se       | Stockholm |
      | Mutts R Us Unpaid | 5562252998     | voof@mutts.se       | Stockholm |
      | HappyMutts Paid   | 2664181183     | hello@happymutts.se | Stockholm |


    # Note that 2 are not members: member_03... and member04...
    And the following applications exist:
      | user_email                       | company_number | categories | state    |
      | member01_exp_jan_3@mutts.se      | 5562252998     | rehab      | accepted |
      | member02_exp_jan_4@mutts.se      | 5562252998     | rehab      | accepted |
      | member03_exp_jan_4@mutts.se      | 5562252998     | rehab      | new      |
      | member04_exp_jan_4@mutts.se      | 5562252998     | rehab      | rejected |
      | member06_exp_jan_15@voof.se      | 2120000142     | rehab      | accepted |
      | member07_exp_jan_16@voof.se      | 2120000142     | rehab      | accepted |
      | member20_exp_mar_2@happymutts.se | 2664181183     | rehab      | accepted |
      | member21_exp_mar_2@happymutts.se | 2664181183     | rehab      | accepted |


    # Everyone in company "happymutts.se" is paid: the H-branding fee is paid
    And the following payments exist
      | user_email                       | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member01_exp_jan_3@mutts.se      | 2018-1-4   | 2019-1-3    | member_fee   | betald | none    |                |
      | member02_exp_jan_4@mutts.se      | 2018-1-5   | 2019-1-4    | member_fee   | betald | none    |                |
      | member06_exp_jan_15@voof.se      | 2018-1-17  | 2019-1-16   | member_fee   | betald | none    |                |
      | member07_exp_jan_16@voof.se      | 2018-1-18  | 2019-1-17   | member_fee   | betald | none    |                |
      | member20_exp_mar_2@happymutts.se | 2018-3-3   | 2019-3-2    | member_fee   | betald | none    |                |
      | member20_exp_mar_2@happymutts.se | 2018-3-3   | 2019-3-2    | branding_fee | betald | none    | 2664181183     |
      | member21_exp_mar_2@happymutts.se | 2018-3-3   | 2019-3-2    | member_fee   | betald | none    |                |

    Given there is a condition with class_name "HBrandingFeePastDueAlert" and timing "after"
    Given the condition has days set to [1, 32, 42, 60, 363 ]


  Scenario Outline: Emails sent when H-Brand Fee Past Due condition is processed
    Given the date is set to <today>
    And the process_condition task sends "condition_response" to the "HBrandingFeePastDueAlert" class
    Then "member01_exp_jan_3@mutts.se" should receive <member01_email> email
    And "member02_exp_jan_4@mutts.se" should receive <memb02_email> email
    And "member06_exp_jan_15@voof.se" should receive <memb06_email> email
    And "member07_exp_jan_16@voof.se" should receive <memb07_email> email
    And "member20_exp_mar_2@happymutts.se" should receive no email
    And "member21_exp_mar_2@happymutts.se" should receive no email

    # mutts.se members will get emails based on 2018-01-04 = day 0 until member01_exp_jan_3 membership expires
    # voof.se  members will get emails based on 2018-01-17 = day 0 until member06_exp_jan_15 membership expires
    Scenarios:
      | today       | member01_email | memb02_email | memb06_email | memb07_email |
      | "2018-1-05" | an             | an           | no           | no           |
      | "2018-1-06" | no             | no           | no           | no           |
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


  Scenario Outline: The earliest membership paid expires; the zero date changes
    Given the date is set to <today>
    And the process_condition task sends "condition_response" to the "HBrandingFeePastDueAlert" class
    Then "member01_exp_jan_3@mutts.se" should receive <member01_email> email
    And "member02_exp_jan_4@mutts.se" should receive <memb02_email> email
    And "member06_exp_jan_15@voof.se" should receive <memb06_email> email
    And "member07_exp_jan_16@voof.se" should receive <memb07_email> email
    And "member20_exp_mar_2@happymutts.se" should receive no email
    And "member21_exp_mar_2@happymutts.se" should receive no email

        # jan 2  = day 363 for mutts.se based on member01_exp_jan_3
        # jan 3  = day 363 for mutts.se based on member02_exp_jan_4
        # jan 15 = day 363 for voof.se based on member06_exp_jan_15
        # jan 16 = day 363 for voof.se based on member07_exp_jan_16
    Scenarios:
      | today       | member01_email | memb02_email | memb06_email | memb07_email |
      | "2019-1-02" | an             | an           | no           | no           |
      | "2019-1-03" | no             | an           | no           | no           |
      | "2019-1-04" | no             | no           | no           | no           |
      | "2019-1-15" | no             | no           | an           | an           |
      | "2019-1-16" | no             | no           | no           | an           |
      | "2019-1-17" | no             | no           | no           | no           |

