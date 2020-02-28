Feature: Order of the list of companies by date last updated

  So that companies other than the first ones added get to be seen at the top of the list of all companies
  Because people usually don't scroll down to see other companies
  Don't put the companies in order by database id ( = order they were added to the db),

  Default to ordering them by date last updated (most recent = first)
  to encourage the company members to come to the SHF site and update information about their company.


  Background:
    Given the date is set to "2020-02-01"

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following kommuns exist:
      | name      |
      | Stockholm |

    And the following business categories exist
      | name    |
      | Groomer |

      # These companies are all in good standing:
      # their H-mark branding fee doesn't expire until 2020-07-07
      # and the background statement above sets 'today' to "2020-02-01".
      # This creates payments and any other data needed.
      # (In the future, if data other than the branding license fee is required to put
      # the company 'in good standing,'  we may want to rename this column.)
      #
    Given the following companies exist:
      | name      | company_number | email           | region    | kommun    | updated_at |
      | Company01 | 5560360793     | cmpy1@mail.com  | Stockholm | Stockholm | 2019-12-01 |
      | Company02 | 2120000142     | cmpy2@mail.com  | Stockholm | Stockholm | 2019-12-05 |
      | Company03 | 6613265393     | cmpy3@mail.com  | Stockholm | Stockholm | 2019-12-22 |
      | Company04 | 6222279082     | cmpy4@mail.com  | Stockholm | Stockholm | 2019-12-02 |
      | Company05 | 8025085252     | cmpy5@mail.com  | Stockholm | Stockholm | 2019-12-03 |
      | Company06 | 6914762726     | cmpy6@mail.com  | Stockholm | Stockholm | 2019-12-04 |
      | Company07 | 7661057765     | cmpy7@mail.com  | Stockholm | Stockholm | 2019-12-23 |
      | Company08 | 7736362901     | cmpy8@mail.com  | Stockholm | Stockholm | 2019-12-26 |
      | Company09 | 6112107039     | cmpy9@mail.com  | Stockholm | Stockholm | 2019-12-28 |
      | Company10 | 3609340140     | cmpy10@mail.com | Stockholm | Stockholm | 2019-12-30 |
      | Company11 | 2965790286     | cmpy11@mail.com | Stockholm | Stockholm | 2019-12-24 |
      | Company12 | 4268582063     | cmpy12@mail.com | Stockholm | Stockholm | 2019-12-25 |
      | Company13 | 8028973322     | cmpy13@mail.com | Stockholm | Stockholm | 2019-12-27 |
      | Company14 | 8356502446     | cmpy14@mail.com | Stockholm | Stockholm | 2019-12-29 |
      | Company15 | 8394317054     | cmpy15@mail.com | Stockholm | Stockholm | 2019-12-31 |


    # These users are all members in good standing:
    # their memberships do not expire until 2020-07-07.
    # and the background statement above sets 'today' to "2020-02-01".
    # This creates accepted applications, payments and any other data needed.
    #
    # WARNING: if you need to have specific SHF application or payment information for a user,
    #  you cannot also use the 'membership expires on' column because the
    #  'membership expires on' will automatically create an accepted SHF application and
    #  payments using RSpec factories. If you also specify SHF application information or
    #  payments here in the Background section, the combination of the data is UNKNOWN.
    #
    And the following users exist:
      | email         | admin | member | updated_at |
      | u1@mutts.com  |       | true   | 2019-12-01 |
      | u2@mutts.com  |       | true   | 2019-12-01 |
      | u3@mutts.com  |       | true   | 2019-12-01 |
      | u4@mutts.com  |       | true   | 2019-12-01 |
      | u5@mutts.com  |       | true   | 2019-12-01 |
      | u6@mutts.com  |       | true   | 2019-12-01 |
      | u7@mutts.com  |       | true   | 2019-12-01 |
      | u8@mutts.com  |       | true   | 2019-12-01 |
      | u9@mutts.com  |       | true   | 2019-12-01 |
      | u10@mutts.com |       | true   | 2019-12-01 |
      | u11@mutts.com |       | true   | 2019-12-01 |
      | u12@mutts.com |       | true   | 2019-12-01 |
      | u13@mutts.com |       | true   | 2019-12-01 |
      | u14@mutts.com |       | true   | 2019-12-01 |
      | u15@mutts.com |       | true   | 2019-12-01 |
      | admin@shf.se  | true  |        | 2019-12-01 |

    And the following payments exist
      | user_email    | start_date | expire_date | payment_type | status | hips_id | company_name |
      | u1@mutts.com  | 2019-07-08 | 2020-07-07  | member_fee   | betald | none    |              |
      | u11@mutts.com | 2019-07-08 | 2020-07-07  | member_fee   | betald | none    |              |
      | u1@mutts.com  | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company01    |
      | u2@mutts.com  | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company02    |
      | u3@mutts.com  | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company03    |
      | u4@mutts.com  | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company04    |
      | u5@mutts.com  | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company05    |
      | u6@mutts.com  | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company06    |
      | u7@mutts.com  | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company07    |
      | u8@mutts.com  | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company08    |
      | u9@mutts.com  | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company09    |
      | u10@mutts.com | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company10    |
      | u11@mutts.com | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company11    |
      | u12@mutts.com | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company12    |
      | u13@mutts.com | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company13    |
      | u14@mutts.com | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company14    |
      | u15@mutts.com | 2019-07-08 | 2020-07-07  | branding_fee | betald | none    | Company15    |


    And the following applications exist:
      | user_email    | company_name | state    | categories |
      | u1@mutts.com  | Company01    | accepted | Groomer    |
      | u2@mutts.com  | Company02    | accepted | Groomer    |
      | u3@mutts.com  | Company03    | accepted | Groomer    |
      | u4@mutts.com  | Company04    | accepted | Groomer    |
      | u5@mutts.com  | Company05    | accepted | Groomer    |
      | u6@mutts.com  | Company06    | accepted | Groomer    |
      | u7@mutts.com  | Company07    | accepted | Groomer    |
      | u8@mutts.com  | Company08    | accepted | Groomer    |
      | u9@mutts.com  | Company09    | accepted | Groomer    |
      | u10@mutts.com | Company10    | accepted | Groomer    |
      | u11@mutts.com | Company11    | accepted | Groomer    |
      | u12@mutts.com | Company12    | accepted | Groomer    |
      | u13@mutts.com | Company13    | accepted | Groomer    |
      | u14@mutts.com | Company14    | accepted | Groomer    |
      | u15@mutts.com | Company15    | accepted | Groomer    |


  Scenario: Visitor sees companies ordered by date last updated
    Given I am logged out
    And I am on the home page
    And I hide the companies search form
    And "items_count" should have "10" selected
    And I should see "10" companies
    And I should see "Company15" in the list of companies
    And I should see "Company15" before "Company10" in the list of companies
    And I should see "Company10" before "Company14" in the list of companies
    And I should see "Company14" before "Company09" in the list of companies
    And I should see "Company09" before "Company13" in the list of companies
    And I should see "Company13" before "Company08" in the list of companies
    And I should see "Company08" before "Company12" in the list of companies
    And I should see "Company12" before "Company11" in the list of companies
    And I should see "Company11" before "Company07" in the list of companies
    And I should see "Company07" before "Company03" in the list of companies
    And I should not see "Company01" in the list of companies
    And I should not see "Company02" in the list of companies
    And I should not see "Company04" in the list of companies
    And I should not see "Company05" in the list of companies
    And I click on the pagination link to go to the next page
    And I should see "5" companies
    And I should see "Company01" in the list of companies
    And I should not see "Company15" in the list of companies
    And I should see "Company02" before "Company06" in the list of companies
    And I should see "Company06" before "Company05" in the list of companies
    And I should see "Company05" before "Company04" in the list of companies
    And I should see "Company04" before "Company01" in the list of companies


  Scenario: When a company is updated (attribute) it should appear at the top of the list
    Given I am logged out
    And I am on the home page
    And I hide the companies search form
    And "items_count" should have "10" selected
    And I should see "10" companies
      # original order before updates
    And I should see "Company15" before "Company10" in the list of companies
    And I should see "Company10" before "Company14" in the list of companies
    And I should see "Company14" before "Company09" in the list of companies
    And I should see "Company09" before "Company13" in the list of companies
    And I should see "Company13" before "Company08" in the list of companies
    And I should see "Company08" before "Company12" in the list of companies
    And I should see "Company12" before "Company11" in the list of companies
    And I should see "Company11" before "Company07" in the list of companies
    And I should see "Company07" before "Company03" in the list of companies

    # member edits company attribute:
    And I am logged in as "u11@mutts.com"
    And I am on the edit company page for "2965790286"
    And I fill in the translated form with data:
      | companies.telephone_number |
      | 12345                      |
    When I click on t("submit")
    Then I should see t("companies.update.success")

    # Recently updated company should be at the top of the list:
    When I am on the home page
    Then I should see "Company11" before "Company15" in the list of companies
    And I should see "Company15" before "Company10" in the list of companies
    And I should see "Company10" before "Company14" in the list of companies
    And I should see "Company14" before "Company09" in the list of companies
    And I should see "Company09" before "Company13" in the list of companies
    And I should see "Company13" before "Company08" in the list of companies
    And I should see "Company08" before "Company12" in the list of companies
    And I should see "Company12" before "Company07" in the list of companies
    And I should see "Company07" before "Company03" in the list of companies


  Scenario: Change the company description using the rich text editor
    Given I am logged out
    And I am on the home page
    And I hide the companies search form
    And "items_count" should have "10" selected
    And I should see "10" companies
        # original order before updates
    And I should see "Company15" before "Company10" in the list of companies
    And I should see "Company10" before "Company14" in the list of companies
    And I should see "Company14" before "Company09" in the list of companies
    And I should see "Company09" before "Company13" in the list of companies
    And I should see "Company13" before "Company08" in the list of companies
    And I should see "Company08" before "Company12" in the list of companies
    And I should see "Company12" before "Company11" in the list of companies
    And I should see "Company11" before "Company07" in the list of companies
    And I should see "Company07" before "Company03" in the list of companies

    # member edits the description in the formatted text editor (ck_editor)
    And I am logged in as "u11@mutts.com"
    And I am on the edit company page for "2965790286"
    And I fill in the translated form with data:
      | companies.description |
      | Hello there!          |
    When I click on t("submit")
    Then I should see t("companies.update.success")

    # Recently updated company should be at the top of the list:
    When I am on the home page
    Then I should see "Company11" before "Company15" in the list of companies
    And I should see "Company15" before "Company10" in the list of companies
    And I should see "Company10" before "Company14" in the list of companies
    And I should see "Company14" before "Company09" in the list of companies
    And I should see "Company09" before "Company13" in the list of companies
    And I should see "Company13" before "Company08" in the list of companies
    And I should see "Company08" before "Company12" in the list of companies
    And I should see "Company12" before "Company07" in the list of companies
    And I should see "Company07" before "Company03" in the list of companies


  Scenario: Add address to a company DOES NOT YET CHANGE SORT ORDER (info associated with a company; not an attribute)
    Given I am logged out
    And I am on the home page
    And I hide the companies search form
    And "items_count" should have "10" selected
    And I should see "10" companies
        # original order before updates
    And I should see "Company15" before "Company10" in the list of companies
    And I should see "Company10" before "Company14" in the list of companies
    And I should see "Company14" before "Company09" in the list of companies
    And I should see "Company09" before "Company13" in the list of companies
    And I should see "Company13" before "Company08" in the list of companies
    And I should see "Company08" before "Company12" in the list of companies
    And I should see "Company12" before "Company11" in the list of companies
    And I should see "Company11" before "Company07" in the list of companies
    And I should see "Company07" before "Company03" in the list of companies

    # member edits info associated with a company (not an attribute):
    And I am logged in as "u11@mutts.com"
    And I am the page for company number "2965790286"
    Then I click on t("companies.show.add_address")
    And I fill in the translated form with data:
      | activerecord.attributes.address.street | activerecord.attributes.address.post_code | activerecord.attributes.address.city |
      | Ålstensgatan 4                         | 123 45                                    | Bromma                               |
    And I select "Stockholm" in select list t("activerecord.attributes.address.region")
    And I select "Stockholm" in select list t("activerecord.attributes.address.kommun")
    And I click on t("submit")
    Then I should see t("addresses.create.success")
    And I should see "123 45"
    And I should see "Bromma"
    And I should see "2" addresses

    # Recently updated company WILL NOT YET be at the top of the list:
    When I am on the home page
#    Then I should see "Company11" before "Company15" in the list of companies
    Then I should see "Company15" before "Company10" in the list of companies
    And I should see "Company10" before "Company14" in the list of companies
    And I should see "Company14" before "Company09" in the list of companies
    And I should see "Company09" before "Company13" in the list of companies
    And I should see "Company13" before "Company08" in the list of companies
    And I should see "Company08" before "Company12" in the list of companies
    And I should see "Company12" before "Company11" in the list of companies
    And I should see "Company11" before "Company07" in the list of companies
    And I should see "Company07" before "Company03" in the list of companies


