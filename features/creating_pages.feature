Feature: Creating pages
  In order to populate the site
  As a cms user
  I want be able to create new pages

  Scenario: Creating a basic page
    Given that I am logged in as a CMS user
    And I am on the admin pages list
    When I click "Add child"
    And I fill in "Title" with "New page title"
    And I press "Create page"
    When I should be on the edit page screen
    And I should see "New page title"