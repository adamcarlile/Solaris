require File.dirname(__FILE__) + '/../spec_helper'

describe Page do

  before(:all) do
    @global_nav = Factory.create(:top_level_folder)
  end
                             
  it "should not be valid when empty" do
    Factory.build(:page, :title => '').should be_invalid
  end

  it "should be valid with correct attributes" do
    Factory.create(:page).should be_valid
  end
  
  it "should set slug correctly" do
    @page = Factory.create(:page, :title => 'Page Title')
    @page.slug.should eql('page-title')
  end
  
  it "should set slug path correctly" do
    @page = Factory.create(:page, :title => 'About us')
    @sub_page = Factory.create(:page, :parent => @page, :title => 'Meet the team')
    @sub_page.slug_path.should eql('about-us/meet-the-team')
  end

  it "should set slug path correctly" do
    @page = Factory.create(:page, :title => 'About us')
    @sub_page = Factory.create(:page, :parent => @page, :title => 'Meet the team')
    @sub_page.slug_path.should eql('about-us/meet-the-team')
  end
  
  it "should find correct published children to show in nav" do
    Factory(:page, :title => 'Published', :parent => @global_nav, :state => 'published', :visible => true)
    Factory(:page, :title => 'Published next week', :parent => @global_nav, :publish_from => 1.week.from_now, :visible => true)
    Factory(:page, :title => 'Not published', :parent => @global_nav)
    @global_nav.published_children_for_nav.length.should eql(1)
  end
  
  
  describe "published named scopes" do
    
    before :each do
      Page.destroy_all
    end

    it "should not return page without published_state" do
      Factory(:page, :state => "draft")
      BasicPage.published.count.should == 0
    end

    it "should return page with published state and null publish_to" do
      page = Factory(:page, :state => "published", :visible => true)
      BasicPage.published.count.should == 1
    end

    it "should return page with published state and publish_from in past and publish_to in future" do
      Factory(:page, :state => "published", :visible => true, :publish_from => 1.day.ago, :publish_to => 1.day.from_now)
      BasicPage.published.count.should == 1
    end

    it "should not return page with published state but publish_from in future" do
      Factory(:page, :state => "published", :visible => true, :publish_from => 1.day.from_now)
      BasicPage.published.count.should == 0
    end

    it "should not return page with published state but publish_to in past" do
      Factory(:page, :state => "published", :publish_to => 1.day.ago)
      BasicPage.published.count.should == 0
    end

  end
  
  describe "position" do
    
    it "should be 1 for new page if it has no siblings" do
      page = Factory(:page, :title => 'Page 1', :parent => @global_nav)
      page.position.should == 1
    end
    
    it "should be highest of siblings on create" do
      p1 = Factory(:page, :title => 'Page 1', :parent => @global_nav)
      p2 = Factory(:page, :title => 'Page 2', :parent => @global_nav)
      p3 = Factory(:page, :title => 'Page 3', :parent => @global_nav)
      p2.position.should be > p1.position
      p3.position.should be > p2.position
    end

    it "should be 1 if siblings position is nil" do
      p1 = Factory(:page, :title => 'Page 1', :parent => @global_nav)
      p2 = Factory(:page, :title => 'Page 2', :parent => @global_nav)
      p1.reload
      p2.reload

      p1.update_attribute(:position, nil)
      p2.update_attribute(:position, nil)
      p1.position.should be_nil
      p2.position.should be_nil

      p3 = Factory(:page, :title => 'Page 3', :parent => @global_nav)
      p3.position.should == 1
    end

  end

  describe "visible?" do
    it "should be true for page with state 'published' and no publish dates" do
      @page = Factory(:published_page, :parent => @global_nav)
      @page.should be_visible
    end
    it "should be true for page with state 'published' and visible and publish_from before today and publish_to after today" do
      @page = Factory(:published_page, :parent => @global_nav, :publish_from => 2.days.ago, :publish_to => 2.days.from_now)
      @page.should be_visible
    end
    it "should be true for page with state 'published' and visible and where both publish_from and publish_to are today" do
      @page = Factory(:published_page, :parent => @global_nav, :publish_from => Time.now, :publish_to => Time.now)
      @page.should be_visible
    end
    it "should be false for page where visible is false" do
      @page = Factory(:page, :parent => @global_nav, :state => 'draft')
      @page.should_not be_visible
    end
    it "should be false for published page with publish_from after today" do
      @page = Factory(:page, :parent => @global_nav, :state => 'published', :publish_from => 1.day.from_now)
      @page.should_not be_visible
    end
    it "should be false for published page with publish_to before today" do
      @page = Factory(:page, :parent => @global_nav, :state => 'published', :publish_to => 1.day.ago)
      @page.should_not be_visible
    end
  end
  
  describe "publish_date" do
    it "should be equal to created_at where publish_from is nil" do
      @page = Factory(:page, :parent => @global_nav, :state => 'published')
      @page.publish_from = nil
      @page.publish_date.should == @page.created_at
    end
    it "should be equal to publish_from if that is not nil" do
      @page = Factory(:page, :parent => @global_nav, :state => 'published', :publish_from => 1.week.ago)
      @page.publish_date.should == @page.publish_from
    end
  end
  
  describe "find_by_slug_path_with_extra_path_params" do
    before(:all) do
      @global_nav.children.each &:destroy
      Factory(:page, :type => "NewsIndex", :state => 'published', :visible => true, :parent => @global_nav, :title => "News")
      Factory(:page, :parent => @global_nav, :state => 'published', :visible => true, :title => 'About us')
    end
    
    it "should return nil for page with invalid path" do
      page,extra_params = Page.find_by_slug_path_with_extra_path_params('foo')
      page.should be_nil
    end
    it "should return correct page record with valid path" do
      page,extra_params = Page.find_by_slug_path_with_extra_path_params('news')
      puts page.should be_a(NewsIndex)
    end
    it "should return nil for correct path with invalid extra path params" do
      page,extra_params = Page.find_by_slug_path_with_extra_path_params('news/a/b/c') # invalid because it takes exactly 2 or 0 extra path params
      page.should be_nil
    end
    it "should return correct page and extra params hash with correct path and valid extra path params" do
      page,extra_params = Page.find_by_slug_path_with_extra_path_params('news/2009/01')
      page.should be_a(NewsIndex)
      extra_params.keys.length.should == 2
      extra_params[:year].should == '2009'
      extra_params[:month].should == '01'
    end
  end

  describe "top_level_page_id" do
    before(:all) do
      @top_level_page = Factory(:page, :parent => @global_nav, :state => 'published')
      @sub_page = Factory(:page, :parent => @top_level_page, :state => 'published')
      @sub_page.reload
    end
    
    it "should equal the id of the page's root ancestor" do
      @sub_page.top_level_page_id.should == @top_level_page.id
    end

    it "should be the same as id if the page is top level" do
      @top_level_page.top_level_page_id.should == @top_level_page.id
    end

    it "should be nil for top level folders (Global nav)" do
      @global_nav.top_level_page_id.should be_nil
    end

  end
  
end
