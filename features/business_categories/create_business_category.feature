Feature: Admin creates business categories; access

  As an admin
  So that members can select the categories that their business falls into
  & so that visitors can search for the business categories they are interested in,
  I need to be able to create business categories

  PT: https://www.pivotaltracker.com/story/show/135009339

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists
    Given the following users exist:
      | email                | admin |
      | applicant@random.com |       |
      | admin@shf.com        | true  |

    And I am logged in as "admin@shf.com"

  Scenario Outline: Admin creates a new Business Category
    Given I am on the "business categories" page
    And I click on t("business_categories.new.title")
    When I fill in the translated form with data:
      | activerecord.attributes.business_category.name | activerecord.attributes.business_category.description |
      | <category_name>                        | <category_description>                        |
    And I click on t("business_categories.form.save")
    And I should see t("business_categories.create.success")
    And I should see "<category_name>"

    Scenarios:
      | category_name    | category_description                                                                                |
      | dog grooming     | washing, brushing, cutting, and trimming hair and nails on dogs                                     |
      | agility training | training dogs to complete agility courses, from beginners to expert competition level               |
      | dog psychology   | addresses behavioural issues of dogs, including the emotional, cognitive, and psycho-social aspects |
      | carting/drafting |                                                                                                     |

  Scenario Outline: Create a new category - when things go wrong
    Given I am on the "business categories" page
    And I click on t("business_categories.new.title")
    When I fill in the translated form with data:
      | activerecord.attributes.business_category.name | activerecord.attributes.business_category.description |
      | <category_name>                        | <category_description>                        |
    When I click on t("business_categories.form.save")
    Then I should see <error>

    Scenarios:
      | category_name | category_description | error                      |
      |               |                      | t("errors.messages.blank") |
      |               | some description     | t("errors.messages.blank") |

  Scenario: Indicate required field
    Given I am on the "business categories" page
    And I click on t("business_categories.new.title")
    Then the field t("activerecord.attributes.business_category.name") should have a required field indicator

  Scenario: Listing Business Categories restricted for Non-admins
    Given I am logged in as "applicant@random.com"
    And I am on the "business categories" page
    Then I should see a message telling me I am not allowed to see that page

  Scenario: Listing Business Categories restricted for visitors
    Given I am Logged out
    And I am on the "business categories" page
    Then I should see a message telling me I am not allowed to see that page
