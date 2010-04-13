require File.dirname(__FILE__) + '/../spec_helper'

describe UserPagePermission do

  before(:all) do
    @user_page_permission = UserPagePermission.new
    User.destroy_all
    @user = Factory(:user, :firstname => 'John', :lastname => 'Smith', :email => 'john@example.com')
    @user_identifier = "John Smith (john@example.com)"
    @page = Factory(:page)
  end

  describe "validation" do
    it "should be invalid without user or page" do
      UserPagePermission.new.should be_invalid
    end
    it "should be invalid if no permissions are enabled" do
      upp = UserPagePermission.new(:user => @user, :page => @page)
      upp.should be_invalid
    end
    it "should be valid with user, page and one permission enabled" do
      upp = UserPagePermission.new(:user => @user, :page => @page, :edit => true)
      upp.should be_valid
    end
    it "should be invalid if a record for this page and user already exists" do
      UserPagePermission.create!(:user => @user, :page => @page, :edit => true)
      upp = UserPagePermission.new(:user => @user, :page => @page, :edit => true)
      upp.should be_invalid
    end
    it "should be invalid if the page isn't allowed to have user permissions assigned to it" do
      upp = UserPagePermission.new(:user => @user, :page => @page, :edit => true)
      upp.page.stubs(:can_have_user_permissions?).returns(false)
      upp.should be_invalid
    end
  end

  describe "user_identifier=" do
    it "should set the user if string contains the email address of an existing user" do
      @user_page_permission.user.should be_nil
      @user_page_permission.user_identifier = @user_identifier
      @user_page_permission.user.should == @user
      @user_page_permission.user_identifier.should == @user_identifier
    end
  end

  describe "user_identifier" do
    it "should be nil if record has no user" do
      @user_page_permission.user_identifier.should be_nil
    end
    it "should return a valid user identifier string if the record has a user" do
      @user_page_permission.user = @user
      @user_page_permission.user_identifier.should ==  @user_identifier
    end
  end

end
