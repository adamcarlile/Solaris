require File.dirname(__FILE__) + '/../spec_helper'

describe SearchIndex do

  before(:all) do
    Page.destroy_all
    @global_nav = Factory.create(:top_level_folder)
    
    Factory(:page, :type => "BasicPage", :visible => true, :state => 'published', :parent => @global_nav, :title => "test page 1", :body => "sausage")
    Factory(:page, :type => "BasicPage", :visible => true, :state => 'published', :parent => @global_nav, :title => "test page 2", :body => "eggs")
    # This page is expired so should not turn up in search results
    Factory(:page, :type => "BasicPage", :visible => true, :state => 'published', :parent => @global_nav, :title => "test page 3", :body => "bacon", :publish_from => 2.months.ago, :publish_to => 2.days.ago)
    # And one from another page type
    Factory(:page, :type => "FaqIndex", :visible => true, :state => 'published', :parent => @global_nav, :title => "Frequently Asked Questions", :body => "Your questions answered")

    `cd #{RAILS_ROOT}; rake environment RAILS_ENV=test xapian:rebuild_index models="Page"`
  end

  describe "indexed_classes" do
    it "should contain all visitable page type classes" do
      SearchIndex.indexed_classes.length.should == 7
      SearchIndex.indexed_classes.should include(BasicPage)
      SearchIndex.indexed_classes.should include(FaqIndex)
      SearchIndex.indexed_classes.should_not include(Question)
    end
  end
  
  describe "search" do
    it "should return an empty collection if no pages match query" do
      SearchIndex.search('qwertyuiop').should be_empty
    end
    it "should return model records" do
      results = SearchIndex.search('eggs')
      results.first.should be_a(BasicPage)
    end
    it "should return pages matching the query" do
      SearchIndex.search('eggs').length.should == 1
      SearchIndex.search('questions').length.should == 1
    end
    it "should not include pages that aren't indexable" do
      SearchIndex.search('bacon').length.should == 0
    end
  end

end
