Feature: Footer contents

  As a visitor
  So that this portation of the SHF site looks like the  main WordPerfect SHF site as much as possible,
  I should see links to the GDPR and Privacy Policy and the terms of purchase in the footer.


  Background:

    Given the Membership Ethical Guidelines Master Checklist exists
    And the application file upload options exist

     # --------------------------------------------------------------------------

  Scenario: Links to GDPR info and Terms of Purchase are in the footer
    Given I am on the home page
    Then I should see t("footer.purchase_terms") in the footer
    And I should see t("footer.gdpr_and_privacy") in the footer
