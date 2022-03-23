Feature: Admin deletes a company

  As an admin
  In order to keep the list of companies valid and up to date
  I need to be able to delete companies

  PT: https://www.pivotaltracker.com/story/show/138063171

  Only delete a company if it is not associated with any ShfApplications,
  other than applications with status == :being_destroyed.

  Only delete the business categories associated with a company
  if those business categories are not associated with any other companies.
  (Holds for each business category independently. So some might be deleted,
  and some might not.)


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                          | admin |
      | emma@happymutts.com            |       |
      | hans@happymutts.com            |       |
      | wils@woof.com                  |       |
      | sam@snarkybarky.com            |       |
      | lars@snarkybarky.com           |       |
      | kitty@kitties.com              |       |
      | meow@kitties.com               |       |
      | under_review@kats.com          |       |
      | ready_for_review@kats.com      |       |
      | waiting_for_applicant@kats.com |       |
      | new@kats.com                   |       |
      | waiting_for_review@kats.com    |       |
      | bob@bowsers.com                |       |
      | admin@shf.se                   | true  |

    And the following business categories exist
      | name        | description                     |
      | grooming    | grooming dogs from head to tail |
      | crooning    | crooning to dogs                |
      | training    | training dogs                   |
      | rehab       | physcial rehab for dogs         |
      | psychology  | mental rehab                    |
      | play-group  | play-group                      |
      | walking     | walking                         |
      | senior-play | senior-play                     |



    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |
      | Norrbotten   |

    Given the following kommuns exist:
      | name      |
      | Alingsås  |
      | Bromölla  |
      | Laxå      |

    And the following companies exist:
      | name                 | company_number | email                 | region       | kommun   |
      | Happy Mutts          | 2120000142     | woof@happymutts.com   | Stockholm    | Alingsås |
      | No More Snarky Barky | 5560360793     | bark@snarkybarky.com  | Stockholm    | Alingsås |
      | WOOF                 | 5569467466     | woof@woof.com         | Västerbotten | Bromölla |
      | Sad Sad Snarky Barky | 5562252998     | sad@sadmutts.com      | Norrbotten   | Laxå     |
      | Unassociated Company | 0000000000     | none@unassociated.com | Norrbotten   | Laxå     |
      | Kitties              | 5906055081     | kitties@kitties.com   | Stockholm    | Alingsås |
      | Kats                 | 9697222900     | kats@kats.com         | Stockholm    | Alingsås |


    And the following applications exist:
      | user_email                     | company_number | state                 | categories    |
      | emma@happymutts.com            | 2120000142     | accepted              | grooming      |
      | hans@happymutts.com            | 2120000142     | accepted              | training      |
      | wils@woof.com                  | 5569467466     | rejected              | walking       |
      | sam@snarkybarky.com            | 5560360793     | rejected              | senior-play   |
      | lars@snarkybarky.com           | 5560360793     | rejected              | rehab         |
      | kitty@kitties.com              | 5906055081     | rejected              | training      |
      | meow@kitties.com               | 5906055081     | rejected              | training      |
      | under_review@kats.com          | 9697222900     | under_review          | psychology    |
      | ready_for_review@kats.com      | 9697222900     | ready_for_review      | psychology    |
      | waiting_for_applicant@kats.com | 9697222900     | waiting_for_applicant | psychology    |
      | new@kats.com                   | 9697222900     | new                   | psychology    |



  # --- policy (permission)

  Scenario: A User cannot delete a company
    Given I am logged in as "bob@bowsers.com"
    When I am on the "all companies" page
    Then I should not see button t("delete")
    When I am the page for company number "5569467466"
    Then I should not see button t("delete")


  Scenario: A Member cannot delete a company
    Given I am logged in as "emma@happymutts.com"
    When I am on the "all companies" page
    Then I should not see t("delete")
    When I am the page for company number "5569467466"
    Then I should not see button t("delete")

  Scenario: A Member cannot delete their company
    Given I am logged in as "emma@happymutts.com"
    When I am the page for company number "5569467466"
    Then I should not see t("delete")
    When I am the page for company number "5569467466"
    Then I should not see button t("delete")

  Scenario: An Admin has the delete button on the companies list page
    Given I am logged in as "admin@shf.se"
    When I am on the "all companies" page
    Then I should see at least one column with class "delete"

  Scenario: An Admin has the delete button on the companies page
    Given I am logged in as "admin@shf.se"
    When I am the page for company number "5569467466"
    Then I should see t("delete")


  # ---- ShfApplications -----

  @selenium
  Scenario: Admin deletes a company with no membership applications and no categories
    Given I am logged in as "admin@shf.se"
    When I am on the "all companies" page
    Then I should see "7" companies
    When I click and accept the icon with CSS class "delete" for the row with "Unassociated Company"
    Then I should see t("companies.destroy.success")
    And I should not see "Unassociated Company"
    And I should see "6" companies

  @selenium
  Scenario: Admin tries to delete a company that has applications
    Given I am logged in as "admin@shf.se"
    When I am on the "business categories" page
    Then I should see "8" business categories
    When I am on the "landing" page
    Then I should see "11" applications
    When I am on the "all companies" page
    Then I should see "7" companies
    When I click and accept the icon with CSS class "delete" for the row with "Kats"
    Then I should see t("companies.destroy.error")

  @selenium
  Scenario: Admin cannot delete a company with 2 (accepted) membership applications
    Given I am logged in as "admin@shf.se"
    When I am on the "business categories" page
    Then I should see "8" business categories
    When I am on the "landing" page
    Then I should see "11" applications
    When I am on the "all companies" page
    Then I should see "7" companies
    When I am on the page for company number "2120000142"
    And I click on and accept the t("companies.index.delete") link
    Then I should not see t("companies.destroy.success")
    And I should see t("companies.destroy.error")
    And I should see t("activerecord.errors.models.company.attributes.company_has_active_memberships")
    When I am on the "all companies" page
    And I should see "Happy Mutts"
    And I should see "7" companies
    When I am on the "business categories" page
    Then I should see "8" business categories
    When I am on the "landing" page
    Then I should see "11" applications

  @selenium
  Scenario: Admin tries to delete a company with 2 rejected membership applications
    Given I am logged in as "admin@shf.se"
    When I am on the "business categories" page
    Then I should see "8" business categories
    When I am on the "landing" page
    Then I should see "11" applications
    When I am on the "all companies" page
    Then I should see "7" companies
    #When I click and accept the t("delete") action for the row with "Kitties"
    When I click and accept the icon with CSS class "delete" for the row with "Kitties"
    Then I should see t("companies.destroy.error")


  @selenium
  Scenario: Admin tries to delete a company with 2 rejected applications and 2 categories (only co. with them)
    Given I am logged in as "admin@shf.se"
    When I am on the "business categories" page
    Then I should see "8" business categories
    When I am on the "landing" page
    Then I should see "11" applications
    When I am on the "all companies" page
    Then I should see "7" companies
    When I click and accept the icon with CSS class "delete" for the row with "No More Snarky Barky"
    Then I should see t("companies.destroy.error")
    Then I am on the "landing" page
    # We do NOT destroy applications when a company is destroyed
    Then I should see "11" applications


  @selenium
  Scenario: Admin tries to delete a company with 1 rejected app, 1 category (only co. associated with it)
    Given I am logged in as "admin@shf.se"
    When I am on the "business categories" page
    Then I should see "8" business categories
    When I am on the "landing" page
    Then I should see "11" applications
    When I am on the "all companies" page
    Then I should see "7" companies
    When I click and accept the icon with CSS class "delete" for the row with "WOOF"

    Then I should see t("companies.destroy.error")
    Then I am on the "business categories" page
    Then I should see "8" business categories
    When I am on the "landing" page
    # We do NOT destroy applications when a company is destroyed
    Then I should see "11" applications
