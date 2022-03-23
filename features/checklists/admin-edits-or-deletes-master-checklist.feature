Feature: Admin edits or deletes a master checklist item
#
#  There are 2 main groups of information about a master checklist item:
#    1. Anything displayed to a user in a User Checklist
#    2. everything else (information _not_ displayed to a user in a user checklist), e.g. notes for administrators only
#
#
#  If there are no user checklist items associated with the item to be replaced,
#  then it can be changed.
#
#  If ANY user checklist items are associated with a master checklist item:
#    Any information displayed to users cannot be changed. (displayed name, description, list position, etc.)
#    Instead, an admin should create a _new_ master checklist item.
#    That new master checklist item will be used from that point in time, forward.
#    Users that had already completed the 'old version' will see the old version.
#    Users that have not yet completed the 'old version' will still see (and complete) the old version.
#
#
#    Ex: Membership Guideline #99: "be nice to dogs"
#
#      2020:
#      -----
#      1 januari:   Guideline #99 "be nice to dogs" created and added to the master checklist "Membership Guidelines"
#
#      2 januari:   Application for User 1 is approved, so the "Membership Guidelines" checklist is created for them
#                   User 1 sees "be nice to dogs" for Guideline #99
#
#      3 januari:   User 1 checks (completes) Guideline #99: "be nice to dogs"
#
#      10 januari:  Application for User 2 is approved, so the "Membership Guidelines" checklist is created for them
#                   User 2 sees "be nice to dogs" for Guideline #99
#
#
#      1 februari:  SHF Board decides the Guideline #99 should say "be nice to ALL dogs"
#
#                   This does not change user checklists that have already been created, whether or not they are completed.
#                   Users 1 and 2 will always see "be nice to dogs" for Guideline #99.
#                   (Once they renew in 2021 they will see a _brand new_ list of all Membership Guidelines they need to agree to.)
#
#      5 februari:  Application for User 3 is approved, so the "Membership Guidelines" checklist is created for them
#                   User 3 sees "be nice to ALL dogs" for Guideline #99
#
#      2021:
#      -----
#      3 januari:   User 1 is due to renew.
#                   User 1 sees "be nice to ALL dogs" for Guideline #99
#
#
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
#  # -------------------------------------------------------------------------
#
#
#  # -----------------
#  # Change something that is not displayed to users: notes
#
#  Scenario: Change the notes of an item that has no user checklists (completed or otherwise)
#   # notes can be changed
#
#  Scenario: Change the notes of an item that has user checklists but no completed user checklists
#  # notes can be changed
#
#  Scenario: Change the notes of an item that has at least 1 completed user checklists
#  # notes can be changed
#
#  # -----------------
#  # Change something that is displayed to users:  Name
#
#  Scenario: Change the name of an item that has no user checklists (completed or otherwise)
#   # it can be changed
#
#  Scenario: Change the name of an item that has user checklists but no completed user checklists
#  # ? warn and ask to change?  users will see something different.
#
#  Scenario: Change the name of an item that has at least 1 completed user checklists
#  # cannot be changed
#
#
#  # -----------------
#  # Change the list position
#
#  Scenario: Change the list position of an item that has no user checklists (completed or otherwise)
#  # it can be changed
#
#  Scenario: Change the list position of an item that has user checklists but no completed user checklists
#  # cannot be changed ?
#
#  Scenario: Change the list position of an item that has at least 1 completed user checklists
#  # cannot be changed ?
