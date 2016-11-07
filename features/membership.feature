Feature: As a user
  In order to be a member
  I need to be able to apply

Scenario: Apply to be a member (Type A) to SHF
  Given I am on the application page
  When I fill in "Förnamn" with "Susanna"
  And I fill in "Efternamn" with "Larsdotter"
  And I fill in "Gatuadress (hela)" with "Street abc 1"
  And I fill in "Postnummer" with "30247"
  And I fill in "Ort" with "Halmstad"
  And I fill in "Telefon (0701223344)" with "0702-123456"
  And I fill in "din@email.se" with "susanna@immi.nu"
  And I fill in "Ange e-post igen" with "susanna@immi.nu"
  And I fill in "Organisationsnr" with "2345678901"
  And I fill in "Ange lösenordet igen" with "password"
  And I fill in "Lösenord (minst 6 tecken)" with "password"
  Then show me the page
  And I press the "Ansök om medlemsskap" button
  Then I should see "Din ansökan är under behandling"
