@public
Feature: Basic pages
  As a guest user
  I want view the homepage and navigate to other basic pages

  Scenario: Visiting the homepage
    When I go to the homepage
    Then I should see the tag "h1" containing "Welcome to our site"
  
  Scenario: Visiting basic pages under About us
    Given I am on the homepage
    When I click "About us"
    Then I should be on the page "about-us/services"
    And I should see the tag "h1" containing "Services"
    When I click "Company"
    And I should see the tag "h1" containing "Company"
    Then I should be on the page "about-us/company"

  Scenario: Visiting the news page and an article within
    Given I am on the homepage
    When I click "News"
    Then I should be on the page "news"
    And I should see the tag "h1" containing "News"
    When I click "Article 1"
    Then I should be on the page "news/article-1"
    And I should see the tag "h1" containing "Article 1"
    When I click "back to news"
    Then I should be on the page "news"

  @focus
  Scenario: Visiting the FAQ page
    Given I am on the homepage
    When I click "FAQ"
    Then I should be on the page "faq"
    And I should see the tag "h1" containing "FAQ"
    And I should see "Question 1?"

  Scenario: Visiting the contact form and submitting an enquiry
    Given I am on the homepage
    When I click "Contact us"
    Then I should be on the page "contact-us"
    And I should see the tag "h1" containing "Contact us"
    When I fill in "Name" with "John"
    And I fill in "Email" with "john@example.com"
    And I fill in "Message" with "Hello"
    And I press "Send message"
    Then I should see "Thank you for your enquiry"
