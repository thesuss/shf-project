Feature: App Config has a missing image or images

  As an admin
  so that it is immediately evident that an image is missing in the Application Configuration
  style the image info and show text so that it really stands out


  Background:

    Given the Membership Ethical Guidelines Master Checklist exists
    Given the following users exist:
      | email             | password | admin | member    | first_name | last_name |
      | admin@shf.se  | password | true  | false     | emma       | admin     |


    And the App Configuration is not mocked and is seeded
    And I am logged in as "admin@shf.se"


    Scenario: Missing site meta image
      Given the "site_meta_image" file is missing from the application configuration
      And I am on the "admin edit app configuration" page
      Then I should see t("admin_only.app_configuration.image_show.missing") in the div with id "site_meta_image"
