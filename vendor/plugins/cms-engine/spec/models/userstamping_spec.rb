require File.dirname(__FILE__) + '/../spec_helper'

describe Page do

  before(:all) do
    User.destroy_all
    @global_nav = Factory.create(:top_level_folder)
    @user = Factory(:user)
  end

  describe "created_by" do
    it "should be set to the current user" do
      @page = Factory.build(:page, :parent => @global_nav)
      @page.current_user = @user
      @page.save
      @page = Page.find(@page.id)
      @page.created_by.should == @user
    end
  end
  describe "updated_by" do
    before(:each) do
      @page = Factory.build(:page, :parent => @global_nav)
      @page.current_user = @user
      @page.save
    end
    it "should be the same as created_by for new page" do
      @page.updated_by.should == @user
    end
    it "should be set to the current user on updating" do
      @page.current_user = @user
      @page.intro = 'Updated intro'
      @page.save
      @page = Page.find(@page.id)
      @page.updated_by.should == @user
    end
    it "should be set to current user when doing an update that will create a new version" do
      @page.current_user = @user
      @page.current_user.should == @user
      @page.intro = 'Updated intro'
      @page.save
      @page.updated_by.should == @user
      # make sure its saved to the database, versioning may effect this
      @page = Page.find(@page.id)
      @page.versions.count.should == 2
      @page.updated_by.should == @user
    end
  end
end
