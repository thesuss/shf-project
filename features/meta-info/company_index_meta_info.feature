Feature: Company index page has meta information set

  Background:

    Given the following users exist
      | email          | admin | member |
      | fanny@woof.com |       | true   |
      | emma@mutts.com |       | true   |
      | admin@shf.se   | true  | false  |

    Given the following companies exist:
      | name       | company_number | email               | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com | Stockholm |
      | Woof       | 6222279082     | woof@woof.com       | Stockholm |

    Given the following applications exist:
      | user_email     | company_number | category_name | state    |
      | emma@mutts.com | 2120000142     | rehab         | accepted |
      | fanny@woof.com | 6222279082     | rehab         | accepted |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.com | 2017-10-1  | 2018-01-31  | branding_fee | betald | none    | 2120000142     |
      | emma@mutts.com | 2017-10-1  | 2018-02-27  | member_fee   | betald | none    |                |
      | fanny@woof.com | 2017-10-1  | 2018-01-31  | branding_fee | betald | none    | 6222279082     |
      | fanny@woof.com | 2017-10-1  | 2018-02-27  | member_fee   | betald | none    |                |



  Scenario: The page has title, description, keywords, og, and twitter meta info set
    Given I am logged out
    When I am on the "landing" page

    Then the page title should be "Hitta H-märkt hundföretag, hundinstruktör | Sveriges Hundföretagare"
    And the page head should include meta "name" "description" with content = "Här hittar du etiska, svenska, H-märkta hundföretag. Du hittar bland annat hundinstruktörer, hundpsykologer, hunddagis, trim med mera."
    And the page head should include meta "name" "keywords" with content = "hund, hundägare, hundinstruktör, hundentreprenör, sveriges hundföretagare, svenskt hundföretag, etisk, h-märkt, hundkurs, rehab"
    And the page head should include a link tag with rel = "image_src" and href = "http://www.example.com/assets/Sveriges_hundforetagare_banner_sajt.jpg"

    And the page head should include a link tag with hreflang = "x-default" and href = "https://hitta.sverigeshundforetagare.se"
    And the page head should include a link tag with hreflang = "sv" and href = "https://hitta.sverigeshundforetagare.se"
    And the page head should include a link tag with hreflang = "en" and href = "https://hitta.sverigeshundforetagare.se/en"

    And the page head should include meta "property" "og:title" with content = "Hitta H-märkt hundföretag, hundinstruktör | Sveriges Hundföretagare"
    And the page head should include meta "property" "og:description" with content = "Här hittar du etiska, svenska, H-märkta hundföretag. Du hittar bland annat hundinstruktörer, hundpsykologer, hunddagis, trim med mera."
    And the page head should include meta "property" "og:type" with content = "website"
    And the page head should include meta "property" "og:url" with content = "http://www.example.com/sv"
    And the page head should include meta "property" "og:locale" with content = "sv_SE"
    And the page head should include meta "property" "og:image" with content = "http://www.example.com/assets/Sveriges_hundforetagare_banner_sajt.jpg"
    And the page head should include meta "property" "og:image:type" with content = "image/jpeg"
    And the page head should include meta "property" "og:image:width" with content = "1245"
    And the page head should include meta "property" "og:image:height" with content = "620"

    And the page head should include meta "name" "twitter:card" with content = "summary"
