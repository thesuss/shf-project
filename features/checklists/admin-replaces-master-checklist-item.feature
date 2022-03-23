Feature: Admin replaces an item in a master checklist
#
#  If completed user checklist items are associated:
#  - the old master checklist item must be marked as 'no longer in use'
#  - the new master checklist item is inserted at the same location position (order)
#
#  If there are no completed user checklist items associated with the item to be replaced:
#  - the old master checklist item is deleted
#  - the new master checklist item is inserted at the same location position (order)
#
#  Background:
#
#    Given the following users exist:
#      | email                                        | admin | member |
#      | admin@shf.se                                 | true  |        |
#      | registered_user_no_app@happymutts.se         |       |        |
#      | applicant_app_only@happymutts.se             |       |        |
#      | applicant_app_and_docs@happymutts.se         |       |        |
#      | applicant_approved_application@happymutts.se |       |        |
#
#
#    Given I am logged in as "admin@shf.se"
#
#    Given the following Master Checklist exist:
#      | name                    | displayed_text                       | description                                             | list position | parent name           |
#      | Membership              | Membership                           | Complete and submit a membership application            |               |                       |
#      | App and Docs Complete   | Application and Supporting Documents | Submit Your Application and Supporting Documents        |               | Membership            |
#      | Submit yer app          | Submit Your Application              | Completed and submit the application                    | 0             | App and Docs Complete |
#      | Supporting Docs         | Provide Documentation                | Provide documents for your business categories (skills) | 1             | App and Docs Complete |
#      | SHF Approved it         | SHF Approved Application             | SHF has approved your application                       | 1             | Membership            |
#      | Pay your membership fee | Pay your membership fee              | Pay your membership (good for 1 year)                   | 2             | Membership            |
#
#
#    Given the following user checklists exist:
#      | user email                                   | checklist name |
#      | registered_user_no_app@happymutts.se         | Membership     |
#      | applicant_app_only@happymutts.se             | Membership     |
#      | applicant_app_and_docs@happymutts.se         | Membership     |
#      | applicant_approved_application@happymutts.se | Membership     |
#
#
#    Given the following user checklist items have been completed:
#      | user email                                   | checklist name  | date completed |
#      | applicant_app_only@happymutts.se             | Submit yer app  | 2019-12-12     |
#      | applicant_app_and_docs@happymutts.se         | Submit yer app  | 2019-12-20     |
#      | applicant_app_and_docs@happymutts.se         | Supporting Docs | 2019-12-20     |
#      | applicant_approved_application@happymutts.se | Submit yer app  | 2019-12-20     |
#      | applicant_approved_application@happymutts.se | Supporting Docs | 2019-12-20     |
#      | applicant_approved_application@happymutts.se | SHF Approved it | 2019-12-20     |
#
#
#  # -------------------------------------------------------------------------
#
#
#  Scenario: Replace an item that has no user checklists (completed or otherwise)
#
#
#  Scenario: Replace an item that has user checklists but no completed user checklists
#
#
#  Scenario: Replace an item that has at least 1 completed user checklists
