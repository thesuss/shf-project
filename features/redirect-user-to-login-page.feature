Feature: Redirect User to the login page if they need to be logged in

  As a visitor
  if I try to access a page that requires me to be logged in
  show me the login page with a message telling me I need to be logged in


  Background:
    Given the following regions exist:
      | name         |
      | Stockholm    |


    Given the following kommuns exist:
      | name     |
      | Alingsås |


    And the following business categories exist
      | name    |
      | Groomer |

    Given the following companies exist:
      | name      | company_number | email           | region       | kommun   |
      | Company01 | 5560360793     | cmpy1@mail.com  | Stockholm    | Alingsås |


    And the following users exists
      | email         | admin | member |
      | u1@mutts.com  |       | true   |

    And the following payments exist
      | user_email    | start_date | expire_date | payment_type | status | hips_id | company_name |
      | u1@mutts.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | Company01    |

    And the following applications exist:
      | user_email    | company_name | state    | categories |
      | u1@mutts.com  | Company01    | accepted | Groomer    |



  Scenario: I try to access a page that requires a login
    Given I am on the "landing" page
    When I am on the "create a new company" page
    Then I should be on "login" page
    Then I should see t("errors.not_permitted")
    And I should see t("errors.try_login")


  Scenario: I try to access an admin page
    Given I am on the "login" page
    When I am on the "all waiting for info reasons" page
    Then I should be on "login" page
    Then I should see t("errors.not_permitted")
    And I should see t("errors.try_login")


  Scenario: I can access a page that does not require a login (detail for 1 company)
    When  I am the page for company number "5560360793"
    Then I should not see t("errors.not_permitted")
    And I should not see t("errors.try_login")
