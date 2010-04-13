require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do

  before(:all) do
    @basic_page = Factory(:page, :type => "BasicPage", :state => 'published', :visible => true, :title => "About us")
    @news_item = Factory(:page, :type => "NewsItem", :state => 'published', :visible => true, :title => "Article 1")
    @news_item_with_comments_disabled = Factory(:page, :type => "NewsItem", :state => 'published', :visible => true, :title => "Article 1", :allow_new_comments => false)
    @comment_attributes = {:name => 'John', :comment => 'Hello'}
  end

  describe "valid?" do
    it "should be false when empty" do
      Comment.new.should_not be_valid
    end
    it "should be false without commentable" do
      comment = Comment.new(@comment_attributes)
      comment.should_not be_valid
    end
    it "should be false for page that can't have comments" do
      comment = @basic_page.comments.build(@comment_attributes)
      comment.should_not be_valid
    end
    it "should be false if comments are disabled for page" do
      comment = @news_item_with_comments_disabled.comments.build
      comment.should_not be_valid
    end
    it "should be false if ip isn't allowed to comment" do
      comment = @news_item.comments.build(@comment_attributes)
      comment.ip = '127.0.0.1'
      comment.stubs(:ip_can_comment?).returns(false)
      comment.should_not be_valid
    end
  end
  
  describe "ip_can_comment?" do
    it "should be true if ip is blank" do
      Comment.new.ip_can_comment?.should be_true
    end
    it "should be true if ip has commented before but before the last hour" do
      previous_comment = @news_item.comments.build(@comment_attributes)
      previous_comment.ip = '127.0.0.1'
      previous_comment.created_at = 90.minutes.ago
      previous_comment.save
      
      comment = Comment.new
      comment.ip = '127.0.0.1'
      comment.ip_can_comment?.should be_true
    end
    it "should be false if ip has commented in the last hour" do
      previous_comment = @news_item.comments.build(@comment_attributes)
      previous_comment.ip = '127.0.0.1'
      previous_comment.created_at = 59.minutes.ago
      previous_comment.save
      
      comment = Comment.new
      comment.ip = '127.0.0.1'
      comment.ip_can_comment?.should be_false
    end
  end

end
