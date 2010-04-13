@public
Feature: Site search
  As a guest user
  I want search the whole site using keywords

  Background:
    Given I am on the homepage

  @focus
  Scenario: Entering a search with no results
    When I fill in "Search" with "antelope"
    And I press "Search"
    Then I should see the tag "h1" containing "Search for “antelope”"
    Then I should see "Sorry, there were no results for your search."

  Scenario: Entering a search with results
    When I fill in "Search" with "services"
    And I press "Search"
    Then I should see the tag "h1" containing "Search for “services”"
    And I should see an element matching "div.search_result" containing "Services"
    When I click "Services" within "div.search_result"
    Then I should be on the page "about-us/services"

  Scenario: Entering a search with a mis-spelled word
    When I fill in "Search" with "compay"
    And I press "Search"
    Then I should see "Did you mean"
    When I click "company" within ".spelling_correction"
    Then I should see the tag "h1" containing "Search for “company”"
