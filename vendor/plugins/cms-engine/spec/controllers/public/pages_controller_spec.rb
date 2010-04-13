require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module URIHelper
  def get_uri_for_page(page, params = {})
    URI.parse(@controller.send(:url_for_page, page, params))
  end
end

describe Public::PagesController do

  include URIHelper
  
  before(:each) do
    @global_nav = Factory(:top_level_folder)
    @news = Factory(:page, :type => "NewsIndex", :state => 'published', :parent => @global_nav, :title => "News")
    @folder = Factory(:page, :type => "Folder", :parent => @global_nav, :state => 'published', :title => 'About us')
    @page = Factory(:page, :parent_id => @folder.id, :state => 'published', :title => 'Services')
    @folder  = Page.find(@folder.id)
    @news  = Page.find(@news.id)
    @page  = Page.find(@page.id)
  end

  describe "url_for_page" do
    
    it "should return url of first child for folder" do
      @folder.reload
      get_uri_for_page(@folder).should == get_uri_for_page(@page)
    end
    
    it "should return correct url for basic page" do
      get_uri_for_page(@page).path.should == '/about-us/services'
    end

    it "should return url with extra params in query string" do
      get_uri_for_page(@news, :page => 5).query.should == 'page=5'
    end
    
    it "should add params to path when page type has extra path params" do
      uri = get_uri_for_page(@news, :year => '2009', :month => '04')
      uri.path.should == '/news/2009/04'
      uri.query.should be_blank
    end

    it "should add query string with params not used in extra path segments" do
      uri = get_uri_for_page(@news, :year => '2009', :month => '04', :page => 5)
      uri.query.should == 'page=5'
    end
    
    it "should not add extra path segments if all required segments are not included in params" do
      uri = get_uri_for_page(@news, :year => '2009', :page => 5) # missing :month
      uri.path.should == '/news'
    end

  end

end
