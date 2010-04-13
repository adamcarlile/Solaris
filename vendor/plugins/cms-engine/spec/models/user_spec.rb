require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  before(:each) do
    User.destroy_all
  end

  describe "validation" do
    it "should create sucessfully with valid attributes" do
      Factory(:user).should be_valid
    end

    it "should not be valid with bad attributes" do
      Factory.build(:user, :email => 'foo').should be_invalid
    end
  end

  describe "has_role?" do
    it "should be true if user has the role in question" do
      @user = Factory(:user)
      @user.roles << Role.find_by_name('admin')
      @user.has_role?(:admin).should be_true
    end
    it "should be false if the user doesn't have the role in question" do
      @user = Factory(:user)
      @user.has_role?(:admin).should be_false      
    end
  end

  describe "permissing checking methods" do
    it "should be true if that method is true for any of the user's roles" do
      @user = Factory(:user)
      @user.roles << Role.find_by_name('cms_user')
      @user.roles << Role.find_by_name('admin')
      @user.can_manage_users?.should be_true
    end
    it "should be false if not true for any of the user's roles " do
      @user = Factory(:user)
      @user.roles << Role.find_by_name('cms_user')
      @user.can_manage_users?.should be_false
    end
  end

  describe "with_roles" do
    it "should return any users with one or more of the supplied zone ids" do
      @regular_user = Factory(:user)
      @cms_user = Factory(:user)
      @cms_user.roles << Role.cms_user
      @writer = Factory(:user)
      @writer.roles << Role.writer
      @editor = Factory(:user)
      @editor.roles << Role.editor
      
      User.with_roles([Role.cms_user.id]).length.should == 1
      User.with_roles([Role.cms_user.id]).should include(@cms_user)

      User.with_roles([Role.cms_user.id, Role.writer.id]).length.should == 2
      
    end
  end
  
end
