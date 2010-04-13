@public
Feature: Commenting
  As a guest user
  I want view be able to post a comment on an article

  Scenario: Adding a comment to a news item
    Given I am on the page "news/article-1"
    When I fill in "Your name" with "Fred"
    When I fill in "E-mail" with "Fred"
    And I fill in "Comment" with "Great article, thanks!"
    And I press "Add comment"
    Then I should be on the page "news/article-1"
    And I should see "Thank you for your comment"
    # because it needs approving first...
    But I should not see "Great article, thanks!" 

  Scenario: Listing
    Given the following comments on the page "news/article-1":
      | name | comment      | approved |
      | John | Very helpful | 1        |
      | Tim  | Good article | 1        |
      | Fred | Dreadful!    | 0        |
    And I am on the page "news/article-1"
    Then I should see "Very helpful"
    And I should see "Good article"
    But I should not see "Dreadful!"
  
  
  