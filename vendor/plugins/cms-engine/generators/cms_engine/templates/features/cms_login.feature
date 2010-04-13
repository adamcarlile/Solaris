@admin
Feature: Admin Login
  In order to manage the website
  As a guest user
  I want log in to the backend

  Scenario: Being redirected to login screen then logging in to the backend
    When I go to the admin dashboard
    Then I should be on the login page
    When I fill in "E-mail address" with "youremail@example.com" 
    And I fill in "Password" with "password"
    And I press "Login"
    Then I should be on the admin dashboard
