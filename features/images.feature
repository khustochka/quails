Feature: Images

  @admin @javascript
  Scenario: Adding observations to an image

    Given logged as administrator
    And locus exists with name_en: "Brovary"
    When I go to the new image page
    When I fill in the following:
      | Code  | test-img-cucumber   |
      | Title | Cucumber test image |
    And I fill in the following within Observations search:
      | Date  | 2008-07-01          |
    And I select "Brovary" from "Location" suggestion within Observations search
    And I press "Save"
  #Then show me the page
    Then I should be on "test-img-cucumber" image page