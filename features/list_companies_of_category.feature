Feature: As a visitor
  In order to easily find a member of a certain category
  I should be able to see the members (companies) of that category listed
  PT: https://www.pivotaltracker.com/story/show/135684057

  Background:
    Given the following users exists
      | email               | admin | is_member |
      | emma@happymutts.com |       | true      |
      | anna@sadmutts.com   |       | true      |
      | admin@shf.se        | true  | true      |

    And the following companies exist:
      | name                 | company_number | email               |
      | No More Snarky Barky | 5562252998     | emma@happymutts.com |
      | Sad Sad Snarky Barky | 2120000142     | anna@sadmutts.com   |

    And the following applications exist:
      | first_name | user_email          | company_number | status  | category_name |
      | Emma       | emma@happymutts.com | 5562252998     | Godkänd | Awesome       |
      | Anna       | anna@sadmutts.com   | 2120000142     | Godkänd | Sadness       |

    And the following business categories exist
      | name    |
      | Awesome |
      | Sadness |

  Scenario: Categories list businesses
    Given I am on the business category "Awesome"
    Then I should see "No More Snarky Barky"
    And I should not see "Sad Sad Snarky Barky"

  Scenario: Categories list businesses
    Given I am on the business category "Sadness"
    Then I should not see "No More Snarky Barky"
    And I should see "Sad Sad Snarky Barky"