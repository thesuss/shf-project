Feature: As a user
  In order to be a member
  I need to be able to apply

Scenario: Apply to be a member (Type A) to SHF
  Given I am on the application page
  When I fill in "First Name" with "Susanna"
  And I fill in "Last Name" with "Larsdotter"
  And I fill in "Street" with "Street abc 1"
  And I fill in "Post nr" with "30247"
  And I fill in "City" with "Halmstad"
  And I fill in "Phone" with "0702-123456"
  And I fill in "E-mail" with "susanna@immi.nu"
  And I fill in "E-mail confirmation" with "susanna@immi.nu"
  And I fill in "Business number" with "2345678901"
  And I fill in "Password confirmation" with "password"
  And I fill in "Password" with "password"
  And I press the "Register" button
  Then I should see "Your application is being processed"
  Then show me the page
