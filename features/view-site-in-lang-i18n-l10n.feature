Feature: As a visitor
  In order to view the site in my language
  I need to be able choose either Swedish or English for the site

  PT: https://www.pivotaltracker.com/story/show/133316647

  Background:
    Given I am Logged out


  Scenario: Default language is Swedish
    Given I am on the "all companies" page
    Then I should see t("companies.index.title")
    And I should not see "Swedish flag" image
    And I should see "English flag" image
    And I should see t("theme_copyright", locale: :sv)


  Scenario: Visitor switches the site language from English to Swedish
    Given I am on the "all companies" page
    When I click on "change-lang-to-english"
    When I click on "change-lang-to-svenska"
    Then I should see t("companies.index.title")
    And I should not see "Swedish flag" image
    And I should see "English flag" image
    And I should see t("theme_copyright", locale: :sv)


  Scenario: Visitor switches the site language from Swedish to English
    Given I am on the "all companies" page
    When I click on "change-lang-to-english"
    Then I should see "Swedish flag" image
    And I should not see "English flag" image
    And I should see t("theme_copyright", locale: :en)

