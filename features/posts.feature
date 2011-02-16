Feature: Species

  @admin
  Scenario: Add post

    Given logged as administrator
    When I go to the new post page
    When I fill in the following:
      | Code   | test-created-in-cucumber |
      | Title  | Cucumber test post       |
      | Text   | Post body                |
      | Status | OPEN                     |
      | Topic  | OBSR                     |
    And I press "Save"
    Then I should be on "test-created-in-cucumber" post page

  @admin
  Scenario: Edit post

    Given a post exists with code: "another-test-post", title: "New title"
    Given logged as administrator
    When I go to "another-test-post" edit post page
    When I fill in the following:
      | Code      | test-edit-post     |
      | Title     | Cucumber test post |
      | Text      | Post body          |
      | Post date | 2009-07-27         |
    And I press "Save"
    Then I should be on "test-edit-post" post page

  @admin
  Scenario: Navigation via Edit this / Show this

    Given a post exists with code: "another-test-post", title: "New title"
    Given logged as administrator
    And I go to "another-test-post" post page
    And I follow "Edit this one"
    Then I should be on "another-test-post" edit post page
    When I follow "Show this one"
    Then I should be on "another-test-post" post page