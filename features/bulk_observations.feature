Feature: Bulk add and edit observations

  @admin @javascript
  Scenario: Bulk add observations form
    Given logged as administrator
    When I go to observations bulk add page
    Then I should see 0 observation rows
    When I click "Add new row"
    Then I should see 1 observation row
    When I click "Add new row"
    Then I should see 2 observation rows

  @admin @no-js
  Scenario: Bulk add form should be able to add one observation if JS is off
    Given logged as administrator
    And locus exists with name_en: "Brovary"
    And species exists with name_sci: "Parus caeruleus", family: "Paridae", code: "parcae"
    When I go to observations bulk add page
    Then I should see 1 observation rows
    When I fill in the following:
      | Location | Brovary         |
      | Date     | 2011-04-08      |
      | Species  | Parus caeruleus |
    And I press "Save"
    Then observation should exist with observ_date: "2011-04-08"