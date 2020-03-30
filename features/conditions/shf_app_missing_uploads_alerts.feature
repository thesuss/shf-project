Feature: Reminder if SHF Application is missing uploaded files (Condition response)

  As a nightly task
  So that applicants are notified ('alerted') if their application
  does not include any uploaded files,
  Email the applicants every X days after the application updated_at date.

  Background:

    Given the date is set to "2018-11-30"
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                                   | admin | member |
      | member01_new@mutts.se                   |       | false  |
      | member02_under_review@mutts.se          |       | false  |
      | member03_waiting_for_applicant@mutts.se |       | false  |
      | member04_rejected@mutts.se              |       | false  |
      | member05_accepted@mutts.se              |       | true   |
      | admin@shf.se                            | true  |        |

    Given the following business categories exist
      | name  | description             |
      | rehab | physical rehabilitation |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name        | company_number | email               | region    |
      | Bow Wow Wow | 2120000142     | hellow@bowwowwow.se | Stockholm |


    And the following applications exist:
      | user_email                              | company_number | categories | state                 |
      | member01_new@mutts.se                   | 5562252998     | rehab      | new                   |
      | member02_under_review@mutts.se          | 5562252998     | rehab      | under_review          |
      | member03_waiting_for_applicant@mutts.se | 5562252998     | rehab      | waiting_for_applicant |
      | member04_rejected@mutts.se              | 5562252998     | rehab      | rejected              |
      | member05_accepted@mutts.se              | 5562252998     | rehab      | accepted              |


    Given there is a condition with class_name "ShfAppNoUploadedFilesAlert" and timing "after"
    Given the condition has days set to [1, 32, 363 ]

  @condition
  Scenario Outline: Application has no uploaded files
    Given the date is set to <today>
    And the process_condition task sends "condition_response" to the "ShfAppNoUploadedFilesAlert" class
    Then "member01_new@mutts.se" should receive <member01_email> email
    And "member02_under_review@mutts.se" should receive <memb02_email> email
    And "member03_waiting_for_applicant@mutts.se" should receive <memb03_email> email
    And "member04_rejected@mutts.se " should receive no email
    And "member05_accepted@mutts.se " should receive no email

    Scenarios:
      | today        | member01_email | memb02_email | memb03_email |
      | "2018-11-30" | no             | no           | no           |
      | "2018-12-01" | an             | an           | an           |
      | "2018-12-31" | no             | no           | no           |
      | "2019-01-01" | an             | an           | an           |
      | "2019-11-28" | an             | an           | an           |
