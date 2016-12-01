Feature: As a (prospective) member
  So that I can display the logo correctly on my site
  I need to read information provied by SHF
  PT: https://www.pivotaltracker.com/story/show/134412599

  Background:
    Given the following users exists
      | email                  |
      | applicant_1@random.com |

    And the following applications exist:
      | first_name | user_email             |
      | Emma       | applicant_1@random.com |

  Scenario: Admin can see an application with multiple business categories given
    Given I am logged in as "applicant_1@random.com"
    And I am on the "landing" page
    And I click on "Medlemssidor"
    Then I should see:
      | content               |
      | Arbetsgrupper         |
      | Mallar                |
      | Medlemsbeviset        |
      | Historiska-dokument   |
      | Nyhetsbrev            |
      | Olycksfallsforsakring |
      | Remiss                |
      | Sociala-medier        |
      | Styrelse              |
    And I should not see "Index"
