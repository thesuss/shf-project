Feature: As a user
  In order to be a member
  I need to be able to apply

Scenario: Apply to be a member (Type A) to SHF
  Given I am on the application page
  When I fill in "user_first_name" with "Susanna"
  And I fill in "user_last_name" with "Larsdotter"
  And I fill in "user_street" with "Street abc 1"
  And I fill in "user_postal_code" with "30247"
  And I fill in "user_city" with "Halmstad"
  And I fill in "user_phone" with "0702-123456"
  And I fill in "user_email" with "susanna@immi.nu"
  And I fill in "user_email_confirmation" with "susanna@immi.nu"
  And I fill in "user_business_number" with "8509044643"
  And I fill in "user_password" with "password"
  And I fill in "user_password_confirmation" with "password"
  And I press the "Ansök om medlemsskap" button
  Then I should see "Welcome! You have signed up successfully."
