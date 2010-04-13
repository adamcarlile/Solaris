require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::PagesController do
  integrate_views

  before(:each) do
    activate_authlogic
    @user = Factory.build(:user, :state => 'active')
    @user.roles = [Role.cms_user, Role.writer]
    UserSession.create! @user
    @global_nav = Factory(:top_level_folder)
  end

  it "should get index sucessfully" do
    get 'index'
    response.should be_success
  end

  describe "create" do

    it "should fail if attributes are not valid" do
      post 'create', :page => Factory.attributes_for(:page, :title => '')
      response.should be_success
      assigns(:page).should be_invalid
    end

    it "should succeed if attributes are valid, and it should default to type BasicPage" do
      attrs = Factory.attributes_for(:page, :parent_id => @global_nav.id, :title => 'Newly created page')

      post 'create', :parent => @global_nav.id, :type => 'page', :page => attrs
      response.should be_redirect
      new_page = Page.find_by_title(attrs[:title])

      new_page.should_not be_nil
      new_page.parent.should == @global_nav
      new_page.should be_a BasicPage
    end

    it "should create a page as a child of the parent selected in the form" do
      parent = Factory(:page)

      attrs = Factory.attributes_for(:page, :parent_id => parent.id, :title => 'Newly created page')
      # Post with global nav as parent param which should be ignored in favour or params[:page][:parent_id]
      post 'create', :parent => @global_nav.id, :type => 'page', :page => attrs
      response.should be_redirect
      new_page = Page.find_by_title(attrs[:title])

      new_page.parent.should == parent
    end

    it "should create page of the chosen type" do
      attrs = Factory.attributes_for(:page, :title => 'Newly created news index', :parent_id => @global_nav.id)
      post 'create', :type => 'news_index', :page => attrs
      response.should be_redirect
      new_page = Page.find_by_title(attrs[:title])
      new_page.class.to_s.should == 'NewsIndex'
    end

    it "should set current_user on @page" do
      attrs = Factory.attributes_for(:page, :parent_id => @global_nav.id, :title => 'Newly created page')
      post 'create', :type => 'news_index', :page => attrs
      assigns(:page).current_user.should == UserSession.find.record
    end

  end

  describe "update" do

    before(:all) do
      @basic_page = Factory(:page, :parent => @global_nav)
      @valid_page_attributes = {:title => "Updated title", :body => "Updated body"}
    end
    
    it "should set current_user on @page" do
      put 'update', :id => @basic_page.id, :page => @valid_page_attributes
      assigns(:page).current_user.should == UserSession.find.record
    end

  end
  
  
  describe "fire_event" do

    before :each do
      @page = Factory(:page)
    end

    it "should call publish! if :publish is a valid event for the object"# do
#      BasicPage.any_instance.expects(:publish!).once
 #     put 'fire_event', :id => @page.id, :event => 'publish'
  #  end

    it "should not call publish! if :publish is a valid event for the object"# do
#      @page.publish!
#      BasicPage.any_instance.expects(:publish!).never
#      put 'fire_event', :id => @page.id, :event => 'publish'
 #   end

  end

end
