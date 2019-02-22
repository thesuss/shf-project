Feature: ld-json info is in the page head on a show company page

  So that the search engines can display info about the company in a
  detailed and helpful way,
  put the company info in the page head in ld+json format


  Background:

    Given the date is set to "2017-07-07"

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following kommuns exist:
      | name     |
      | Alingsås |

    Given the following companies exist:
      | name     | company_number | email          | region    | kommun   | visibility     |
      | Company1 | 5560360793     | cmpy1@mail.com | Stockholm | Alingsås | street_address |


    And the following users exists
      | email           | admin | member |
      | user1@mutts.com |       | true   |
      | admin@shf.se    | true  | false  |

    Given the following payments exist
      | user_email      | start_date | expire_date | payment_type | status | hips_id |
      | user1@mutts.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |


    And the following business categories exist
      | name    |
      | Groomer |


    And the following applications exist:
      | user_email      | company_number | categories | state    |
      | user1@mutts.com | 5560360793     | Groomer    | accepted |


    And the following payments exist
      | user_email      | start_date | expire_date | payment_type | status | hips_id | company_number |
      | user1@mutts.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |


  Scenario: Company info as meta JSON-ld is in the page head
    Given I am Logged out
    And I am the page for company number "5560360793"
    And the page head should include a ld+json script tag with key "name" and value "Company1"
    And the page head should include a ld+json script tag with key "description" and value ""
    And the page head should include a ld+json script tag with key "url" and value "http://www.example.com"
    And the page head should include a ld+json script tag with key "email" and value "cmpy1@mail.com"
    And the page head should include a ld+json script tag with key "telephone" and value "123123123"
    And the page head should include a ld+json script tag with key "location" and subkey "address" and subkey2 "streetAddress" and value "Hundforetagarevägen 1"
    And the page head should include a ld+json script tag with key "location" and subkey "address" and subkey2 "postalCode" and value "310 40"
    And the page head should include a ld+json script tag with key "location" and subkey "address" and subkey2 "addressRegion" and value "Stockholm"
    And the page head should include a ld+json script tag with key "location" and subkey "address" and subkey2 "addressLocality" and value "Harplinge"
    And the page head should include a ld+json script tag with key "location" and subkey "address" and subkey2 "addressCountry" and value "Sverige"
    And the page head should include a ld+json script tag with key "location" and subkey "geo" and subkey2 "latitude" and value "60.128161"
    And the page head should include a ld+json script tag with key "location" and subkey "geo" and subkey2 "longitude" and value "18.643501"
