@public
Feature: Tags
  As a guest user
  I want view a list of tags and click through to view items with that tag

  Scenario: Visiting the homepage
    When I go to the tags page
    Then I should see the tag "h1" containing "Tags"
    And I should see "tag 1"
    And I should see "tag2"
    And I should see "tag3"

  Scenario: Viewing items with a particular tag and clicking through
    Given I am on the tags page
    When I click "tag 1"
    Then I should see the tag "h1" containing "Items tagged with"
    Then I should see the tag "h1" containing "tag 1"
    And I should see "Services"
    When I click "Services"
    Then I should be on the page "about-us/services"
  
  