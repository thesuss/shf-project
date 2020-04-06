Feature: User or Member checks or unchecks a user checklist item as completed

  As a user or member,
  When I complete an item on one of my checklists,
  I need to be able to manually check is as completed (or uncheck it)
  So that SHF knows of my progress

#
#  Background:
#
#    Given the date is set to "2020-02-02"
#    Given the Membership Ethical Guidelines Master Checklist exists
#
#    Given the following users exist:
#      | email                | admin | member | first_name | last_name |
#      | applicant@random.com |       |        | Kicki      | Applicant |
#      | member@random.com    |       | true   | Lars       | Member    |
#      | admin@shf.se         | yes   |        |            |           |
#
##
##      | name                          | displayed_text   | list position | parent name       |
##      | Medlemsåtagande               | Medlemsåtagande  |               |                   |
##      | Section 1                     | Section 1        | 0             | Medlemsåtagande   |
##      | Guideline 1.1                 | Guideline 1.1    | 0             | Section 1         |
##      | Guideline 1.2                 | Guideline 1.2    | 1             | Section 1         |
##      | Section 2                     | Section 2        | 1             | Medlemsåtagande   |
##      | Guideline 2.1                 | Guideline 2.1    | 0             | Section 2         |
#
#
#    Given the following user checklist items have been completed:
#      | user email           | checklist name   | date completed |
#      | applicant@random.com | Guideline 1.2    | 2020-02-03     |
#      | applicant@random.com | Guideline 1.1    | 2020-02-02     |
#      | member@random.com    | Medlemsåtagande | 2020-02-02     |
#
#
#
#  @selenium
#  Scenario: User sees first membership guideline to check
#
#
#  @selenium
#  Scenario: User sees next guideline to check after checking the previous one
#
#
#  @selenium
#  Scenario: User sees completed checklist page once all are checked
#  # on the list progress page, all are shown as completed
#
#
#  @selenium
#  Scenario: Member sees line saying Membership Guidelines are completed;links to guidelines on main SHF site
#  # On the user profile page, sees the line
