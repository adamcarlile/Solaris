require File.dirname(__FILE__) + '/../spec_helper'

describe Page do

  before(:all) do
    @global_nav = Factory.create(:top_level_folder)
    @page1 = Factory.create(:page, :parent => @global_nav, :title => 'Section')
    @page2 = Factory.create(:page, :parent => @page1, :title => 'Sub page')
    @page3 = Factory.create(:page, :parent => @global_nav, :title => 'Section 2')
    @page4 = Factory.create(:page, :parent => @page3, :title => 'Sub page 2')

  end
  before :each do
    User.destroy_all
    @user = Factory(:user)
    
    @editor1 = Factory(:user)
    @editor1.roles = Role.all
    @editor2 = Factory(:user)
    @editor2.roles = Role.all
    @cms_user1 = Factory(:user)
    @cms_user1.roles << Role.cms_user
    @cms_user2 = Factory(:user)
    @cms_user2.roles << Role.cms_user
    
  end

  describe "editable_by?" do
    it "should be false if user doesn't have writer role" do
      @page2.editable_by?(@user).should be_false
    end
    it "should be true if user has writer role" do
      @user.roles << Role.writer
      @page2.editable_by?(@user).should be_true
    end
    it "should be true if user doesn't have writer role but has_permission_for_user with 'edit' is true" do
      @page1.stubs(:has_permission_for_user?).with(:edit, @user).returns(true)
      @page1.editable_by?(@user).should be_true
    end
  end
    
  describe "has_permission_for_user?" do
    it "should be false if page doesn't have a root ancestor (Global nav etc.)" do
      @global_nav.has_permission_for_user?(:edit, @user).should be_false
    end
    it "should be false if the page's root ancestor doesn't have the given permission for the user" do
      @page1.user_page_permissions.create!(:user => @user, :publish => true) # user has permission for this page but not 'edit'
      @page1.has_permission_for_user?(:edit, @user).should be_false
    end
    it "should be true if page has the given permission for the user" do
      @page1.user_page_permissions.create!(:user => @user, :edit => true)
      @page1.has_permission_for_user?(:edit, @user).should be_true
    end
    it "should be true if page's root ancestor has the given permission for the user" do
      @page1.user_page_permissions.create!(:user => @user, :edit => true)
      @page2.has_permission_for_user?(:edit, @user).should be_true
    end
  end
  
  describe "editable_by named scope" do
    it "should return only pages within top level section that user has publish permissions for" do
      @user.user_page_permissions.create!(:page_id => @page1.id, :publish => true)
      Page.editable_by(@user).count.should == 2
    end
  end
  
  describe "users_who_can_publish" do
    it "should include all users with editor role and users with publish rights for that page's root ancestor" do
      @page1.user_page_permissions.create!(:user => @cms_user1, :publish => true)
      @page1.user_page_permissions.create!(:user => @cms_user2, :edit => true)

      @page2.users_who_can_publish.should include(@editor1)
      @page2.users_who_can_publish.should include(@editor2)

      @page2.users_who_can_publish.should include(@cms_user1) # who is assigned to the root page with publish rights
      @page2.users_who_can_publish.should_not include(@cms_user2) # who is assigned to the root page with edit rights only
    end
    it "should not fail for page without a root ancestor e.g. global nav" do
      @global_nav.users_who_can_publish.should include(@editor1)
    end
  end

end