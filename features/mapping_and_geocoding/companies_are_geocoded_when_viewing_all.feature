Feature: All companies are geocoded before being shown on the view all companies page
  As a visitor,
  so all companies are mapped when I look at the list of them,
  geocode any companies that aren't yet geocoded before everything is displayed.

  Background:
    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following companies exist:
      | name                 | company_number | email                  | region       |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm    |
      | Bowsers              | 2120000142     | bowwow@bowsersy.com    | Västerbotten |


    And the following users exists
      | email               | admin |
      | emma@happymutts.com |       |
      | a@happymutts.com    |       |
      | admin@shf.se        | true  |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Trainer      |

    And the following applications exist:
      | first_name | user_email          | company_number | category_name | state    |
      | Emma       | emma@happymutts.com | 5560360793     | Groomer       | accepted |
      | Anna       | a@happymutts.com    | 2120000142     | Trainer       | accepted |



  Scenario: A company that isn't geocoded is geocoded before all are viewed
    Given all addresses for the company named "No More Snarky Barky" are not geocoded
    And all addresses for the company named "Bowsers" are not geocoded
    And I am Logged out
    When I am on the "landing" page
    Then all addresses for the company named "No More Snarky Barky" should be geocoded
    And all addresses for the company named "Bowsers" should be geocoded

