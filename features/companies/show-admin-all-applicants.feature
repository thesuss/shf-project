Feature: Admin sees all applicants connected to a company

  As an admin
  So that I can see everyone that has applied to SHF that has listed a Company
  Show me all applicants when I view info about a company


  PivotalTracker: https://www.pivotaltracker.com/story/show/177251184

  Background:
    Given the date is set to "2021-03-02"
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                              | admin | member | agreed_to_membership_guidelines | first_name   | last_name |
      | member@example.com                 |       | true   | yes                             | Current      | Member    |
      | applicant-new@example.com          |       | false  | yes                             | New          | Applicant |
      | applicant-under-review@example.com |       | false  | yes                             | Under Review | Applicant |
      | applicant-rejected@example.com     |       | false  | yes                             | Rejected     | Applicant |
      | admin@shf.se                       | true  | false  | yes                             | Admin        | Admin     |

    And the following business categories exist
      | name    |
      | Groomer |

    And the following companies exist:
      | name                 | company_number | email                   | region    | kommun   | city      | visibility     |
      | No More Snarky Barky | 5560360793     | hello@nosnarkybarky.com | Stockholm | Alingsås | Harplinge | street_address |

    And the following applications exist:
      | user_email                         | company_number | categories | state        |
      | member@example.com                 | 5560360793     | Groomer    | accepted     |
      | applicant-new@example.com          | 5560360793     | Groomer    | new          |
      | applicant-under-review@example.com | 5560360793     | Groomer    | under_review |
      | applicant-rejected@example.com     | 5560360793     | Groomer    | rejected     |


    And the following payments exist
      | user_email         | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member@example.com | 2021-01-01 | 2021-12-31  | member_fee   | betald | none    |                |
      | member@example.com | 2021-01-01 | 2021-12-31  | branding_fee | betald | none    | 5560360793     |


    # And the following memberships exist:

  # -----------------------------------------------------------------------------------------------

  Scenario: Admin sees member and applicants section with 3 applicants on Company page
    Given I am logged in as "admin@shf.se"
    When I am on the page for company number "5560360793"
    Then I should see "No More Snarky Barky" in the h1 title
    And I should see t("companies.company_members.title")
    And I should see "Current Member"
    And I should see t("companies.company_applicants.title")
    And I should see "New Applicant"
    And I should see "Under Review Applicant"
    And I should see "Rejected Applicant"


  Scenario: Admin sees links to each person and application and the date each app was last updated
    Given I am logged in as "admin@shf.se"
    When I am on the page for company number "5560360793"
    Then I should see "No More Snarky Barky" in the h1 title
    And I should see "Current Member"
    And I should see "Current Member" link
    And I should see t("companies.company_applicants.title")
    And I should see "New Applicant" link
    And I should see "Under Review Applicant" link
    And I should see "Rejected Applicant" link
    And I should see 4 visible "2021-03-02"


  Scenario Outline: Non-admins do not see non-member applicants listed
    Given I am <logged_in_status>
    When I am on the page for company number "5560360793"
    Then I should see "No More Snarky Barky" in the h1 title
    And I should see "Current Member"
    And I should not see t("companies.company_applicants.title")
    And I should not see "New Applicant"
    And I should not see "Under Review Applicant"
    And I should not see "Rejected Applicant"

    Scenarios:
      | logged_in_status                         |
      | logged in as "member@example.com"        |
      | logged in as "applicant-new@example.com" |
      | logged out                               |


  Scenario: Non-admins do not see links to each person and application
    Given I am <logged_in_status>
    When I am on the page for company number "5560360793"
    Then I should see "No More Snarky Barky" in the h1 title
    And I should see "Current Member"
    And I should not see "Current Member" link

    Scenarios:
      | logged_in_status                         |
      | logged in as "member@example.com"        |
      | logged in as "applicant-new@example.com" |
      | logged out                               |
