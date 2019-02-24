Feature: Alerts sent if Company info is incomplete (a Condition response)

  As a nightly task
  So that users are notified ('alerted') if information for a company is incomplete
  for a company they are associated with,
  alert them of this by sending an email to them.

  (reminder: "current member" = approved AND paid membership fee)


  Background:
    Given the date is set to "2018-01-01"


    Given the following users exists
      | email                              | admin | member |
      | memb01_paid_jan01@nil-region.se    |       | true   |
      | memb02_paid_jan03@nil-region.se    |       | true   |
      | memb03_paid_jan10@blank-co-name.se |       | true   |
      | memb04_paid_jan15@blank-co-name.se |       | true   |
      | memb20@complete_company.se         |       | true   |
      | memb21@complete_company.se         |       | true   |
      | admin@shf.se                       | true  |        |


    Given the following business categories exist
      | name  | description             |
      | rehab | physical rehabilitation |


    Given the following regions exist:
      | name      |
      | Stockholm |


    Given the following companies exist:
      | name                    | company_number | region    |
      | this name will be blank | 2120000142     | Stockholm |
      | Blank region            | 5562252998     | Stockholm |
      | Complete Company        | 2664181183     | Stockholm |


    Given the following applications exist:
      | user_email                         | company_number | categories | state    | when_approved |
      | memb01_paid_jan01@nil-region.se    | 5562252998     | rehab      | accepted | 2018-01-01    |
      | memb02_paid_jan03@nil-region.se    | 5562252998     | rehab      | accepted | 2018-01-01    |
      | memb03_paid_jan10@blank-co-name.se | 2120000142     | rehab      | accepted | 2018-01-01    |
      | memb04_paid_jan15@blank-co-name.se | 2120000142     | rehab      | accepted | 2018-01-01    |
      | memb20@complete_company.se         | 2664181183     | rehab      | accepted | 2018-01-01    |
      | memb21@complete_company.se         | 2664181183     | rehab      | accepted | 2018-01-01    |


    Given the following payments exist
      | user_email                         | start_date | expire_date | payment_type | status | hips_id | company_number |
      | memb01_paid_jan01@nil-region.se    | 2018-1-1   | 2018-12-31  | member_fee   | betald | none    |                |
      | memb02_paid_jan03@nil-region.se    | 2018-1-3   | 2019-01-02  | member_fee   | betald | none    |                |
      | memb01_paid_jan01@nil-region.se    | 2018-1-1   | 2018-12-31  | branding_fee | betald | none    | 5562252998     |
      | memb03_paid_jan10@blank-co-name.se | 2018-1-10  | 2019-01-09  | member_fee   | betald | none    |                |
      | memb03_paid_jan10@blank-co-name.se | 2018-1-10  | 2019-01-09  | branding_fee | betald | none    | 2120000142     |
      | memb04_paid_jan15@blank-co-name.se | 2018-1-15  | 2019-01-14  | member_fee   | betald | none    |                |
      | memb20@complete_company.se         | 2018-1-1   | 2018-12-31  | member_fee   | betald | none    |                |
      | memb20@complete_company.se         | 2018-1-1   | 2018-12-31  | branding_fee | betald | none    | 2664181183     |
      | memb21@complete_company.se         | 2018-1-1   | 2018-12-31  | member_fee   | betald | none    |                |


    Given there is a condition with class_name "CompanyInfoIncompleteAlert" and timing "after"
    Given the condition has days set to [1, 7, 14, 363 ]


  Scenario Outline: emails go out only to members of companies with incomplete info
    Given the date is set to <today>
    And the name for company number "2120000142" is set to an empty string
    And the region for company named "Blank region" is set to nil
    And the process_condition task sends "condition_response" to the "CompanyInfoIncompleteAlert" class
    Then "memb01_paid_jan01@nil-region.se" should receive <member01_email> email
    And "memb02_paid_jan03@nil-region.se" should receive <memb02_email> email
    And "memb03_paid_jan10@blank-co-name.se" should receive <memb03_email> email
    And "memb04_paid_jan15@blank-co-name.se" should receive <memb04_email> email
    And "memb20@complete_company.se" should receive no email
    And "memb21@complete_company.se" should receive no email

    Scenarios:
      | today        | member01_email | memb02_email | memb03_email | memb04_email |
      | "2018-01-01" | no             | no           | no           | no           |
      | "2018-01-02" | an             | an           | no           | no           |
      | "2018-01-03" | no             | no           | no           | no           |
      | "2018-01-07" | no             | no           | no           | no           |
      | "2018-01-08" | an             | an           | no           | no           |
      | "2018-01-09" | no             | no           | no           | no           |
      | "2018-01-10" | no             | no           | no           | no           |
      | "2018-01-11" | no             | no           | an           | an           |
      | "2018-01-12" | no             | no           | no           | no           |
      | "2018-01-14" | no             | no           | no           | no           |
      | "2018-01-15" | an             | an           | no           | no           |
      | "2018-01-16" | no             | no           | no           | no           |
      | "2018-01-17" | no             | no           | an           | an           |
      | "2018-01-18" | no             | no           | no           | no           |
      | "2018-12-29" | no             | no           | no           | no           |
      | "2018-12-30" | an             | an           | no           | no           |
      | "2018-12-31" | no             | no           | no           | no           |
      | "2019-01-01" | no             | an           | no           | no           |
      | "2019-01-07" | no             | no           | no           | no           |
      | "2019-01-08" | no             | no           | an           | an           |
      | "2019-01-12" | no             | no           | no           | no           |
      | "2019-01-13" | no             | no           | no           | an           |
      | "2019-01-14" | no             | no           | no           | no           |
