Feature: Species

  Scenario: Add post

    When I go to the new post page
    When I fill in the following:
      | Code   | test-created-in-cucumber |
      | Title  | Cucumber test post       |
      | Text   | Post body                |
      | Status | OPEN                     |
      | Topic  | OBSR                     |
    And I press "Create Post"
    Then I should be on "test-created-in-cucumber" post page

