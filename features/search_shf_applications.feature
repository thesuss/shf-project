Feature: Admin can search Shf Applications

  As an admin for the site
  In order to find find and manage applications
  I want to search for applications by various criteria

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | first_name | last_name | email               | admin | membership_number |
      | Fred       | Fransson  | fred@barkyboys.com  |       | 3                 |
      | John       | Johanssen | john@happymutts.com |       | 14                |
      | Anna       | Anderson  | anna@dogsrus.com    |       | 1                 |
      | Emma       | Eriksson  | emma@weluvdogs.com  |       | 2                 |
      | admin      | admin     | admin@shf.se        | true  |                   |

    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Walker       |

    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |
      | Norrbotten   |
      | Sweden       |

    And the following companies exist:
      | name        | company_number | email               | region       |
      | Barky Boys  | 5560360793     | barky@barkyboys.com | Stockholm    |
      | HappyMutts  | 2120000142     | woof@happymutts.com | Västerbotten |
      | Dogs R Us   | 5562252998     | chief@dogsrus.com   | Norrbotten   |
      | We Luv Dogs | 5569467466     | alpha@weluvdogs.com | Sweden       |

    And the following applications exist:
      | user_email          | company_number | state        | categories   |
      | fred@barkyboys.com  | 5560360793     | rejected     | Groomer      |
      | john@happymutts.com | 2120000142     | accepted     | Psychologist |
      | anna@dogsrus.com    | 5562252998     | new          | Trainer      |
      | emma@weluvdogs.com  | 5569467466     | under_review | Walker       |

    And I am logged in as "admin@shf.se"
    And I am on the "membership applications" page


  @selenium
  Scenario: Search by user's last name
    And I should see "Fred"
    And I should see "John"
    And I should see "Anna"
    And I should see "Emma"
    Then I select "Fransson" in select list t("activerecord.attributes.shf_application.last_name")
    And I click on t("search")
    And I should see "Fransson, Fred"
    And I should not see "John"
    And I should not see "Anna"
    And I should not see "Emma"

  @selenium
  Scenario: Search by company (org) number
    Then I select "5569467466" in select list t("shf_applications.index.org_nr")
    And I click on t("search")
    Then I should see "Eriksson, Emma"
    And I should not see "John"
    And I should not see "Anna"
    And I should not see "Fred"
    Then I select "2120000142" in select list t("shf_applications.index.org_nr")
    And I click on t("search")
    Then I should see "Eriksson, Emma"
    Then I should see "Johanssen, John"

  @selenium
  Scenario: Search by status
    Then I select t("activerecord.attributes.shf_application.state/under_review") in select list t("shf_applications.index.state")
    And I click on t("search")
    And I should see "Eriksson, Emma"
    And I should not see "John"
    And I should not see "Anna"
    And I should not see "Fred"
    Then I select t("activerecord.attributes.shf_application.state/new") in select list t("shf_applications.index.state")
    And I click on t("search")
    And I should see "Eriksson, Emma"
    And I should see "Anderson, Anna"
    And I should not see "John"
    And I should not see "Fred"

  @selenium
  Scenario: Search by status and company number
    Then I select t("activerecord.attributes.shf_application.state/under_review") in select list t("shf_applications.index.state")
    Then I select "2120000142" in select list t("shf_applications.index.org_nr")
    And I click on t("search")
    And I should not see "Emma"
    And I should not see "John"
    And I should not see "Anna"
    And I should not see "Fred"
    Then I select "5569467466" in select list t("shf_applications.index.org_nr")
    And I click on t("search")
    And I should see "Eriksson, Emma"
    And I should not see "John"
    And I should not see "Anna"
    And I should not see "Fred"

  @selenium
  Scenario: Search by membership number
    Then I select "1" in select list t("shf_applications.index.membership_number")
    And I click on t("search")
    Then I should see "Anderson, Anna"
    And I should not see "John"
    And I should not see "Emma"
    And I should not see "Fred"
    Then I select "14" in select list t("shf_applications.index.membership_number")
    And I click on t("search")
    Then I should see "Johanssen, John"

  @selenium
  Scenario: Can sort by user lastname
    Then I click on t("shf_applications.index.name") link
    And I should see "Anderson" before "Eriksson"
    And I should see "Eriksson" before "Fransson"
    And I should see "Fransson" before "Johanssen"
    Then I click on t("shf_applications.index.name") link
    And I should see "Johanssen" before "Fransson"
    And I should see "Fransson" before "Eriksson"
    And I should see "Eriksson" before "Anderson"

  @selenium
  Scenario: Can sort by user membership number (TBD - how to ensure we are checking info in the body and not search lists?)
    Then I click on t("shf_applications.index.membership_number") link
    And I should see "Anderson" before "Eriksson"
    And I should see "Eriksson" before "Fransson"
    And I should see "Fransson" before "Johanssen"
    Then I click on t("shf_applications.index.membership_number") link
    And I should see "Johanssen" before "Fransson"
    And I should see "Fransson" before "Eriksson"
    And I should see "Eriksson" before "Anderson"


#  @selenium
#  Scenario: Can sort by company number (Org Nr.) (TBD - how to ensure we are checking info in the body and not search lists?)


#  @selenium
#  Scenario: Can sort by status: TBD - Ransacker will only search on db table columns.  So how to do this on I18n.translated entries?  OR - change data in db to svenska


  @selenium
  Scenario: list of Statuses are translated correctly (default locale)
    Then I should not see t("activerecord.attributes.shf_application.state/new", locale: :en)
    And I should not see t("activerecord.attributes.shf_application.state/under_review", locale: :en)
    And I should not see t("activerecord.attributes.shf_application.state/accepted", locale: :en)
    And I should not see t("activerecord.attributes.shf_application.state/rejected", locale: :en)
    And I should not see t("activerecord.attributes.shf_application.state/waiting_for_applicant", locale: :en)
    And I should not see t("activerecord.attributes.shf_application.state/ready_for_review", locale: :en)
