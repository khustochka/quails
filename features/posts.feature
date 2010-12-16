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

  Scenario: Edit post

    Given a post exists with code: "another-test-post", title: "New title"
    When I go to "another-test-post" edit post page
    When I fill in the following:
      | Code      | test-edit-post      |
      | Title     | Cucumber test post  |
      | Text      | Post body           |
    And I select "2009-07-27" as the "Post date" date
    And I press "Update Post"
    Then I should be on "test-edit-post" post page

  Scenario: Navigation via Edit this / Show this

    Given a post exists with code: "another-test-post", title: "New title"
    When I go to "another-test-post" post page
    And I follow "Edit this one"
    Then I should be on "another-test-post" edit post page
    When I follow "Show this one"
    Then I should be on "another-test-post" post page


