@javascript @admin
Feature: Bulk add and edit observations

  Scenario: Bulk add observations form
    Given logged as administrator
    When I go to observations bulk add page
    Then I should see 0 observation rows
    When I click "Add new row"
    Then I should see 1 observation row
    When I click "Add new row"
    Then I should see 2 observation rows