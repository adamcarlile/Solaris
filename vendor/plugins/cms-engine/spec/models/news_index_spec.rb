require File.dirname(__FILE__) + '/../spec_helper'

describe NewsIndex do

  before(:all) do
    NewsIndex.destroy_all
    NewsItem.destroy_all
    @news_index = Factory(:page, :type => "NewsIndex", :state => 'published', :title => "News")
    # one not published
    Factory(:page, :type => "NewsItem", :created_at => Date.new(2008,11,1), :state => 'draft', :parent => @news_index)
    # 2 on different months
    Factory(:page, :type => "NewsItem", :created_at => Date.new(2008,12,1), :state => 'published', :visible => true, :parent => @news_index)
    Factory(:page, :type => "NewsItem", :created_at => Date.new(2009,1,10), :state => 'published', :visible => true, :parent => @news_index)
    # 2 from same month
    Factory(:page, :type => "NewsItem", :created_at => Date.new(2009,2,10), :state => 'published', :visible => true, :parent => @news_index)
    Factory(:page, :type => "NewsItem", :created_at => Date.new(2009,2,20), :state => 'published', :visible => true, :parent => @news_index)

  end

  describe "in_date_range" do
    it "should return items within given range" do
      jan_09 = (Date.new(2009,1) .. Date.new(2009,1,31))
      news_items = NewsItem.in_date_range( jan_09 )
      news_items.length.should == 1
      feb_09 = (Date.new(2009,2) .. Date.new(2009,2,28))
      news_items = NewsItem.in_date_range( feb_09 )
      news_items.length.should == 2
      news_items.all?{|n| feb_09.include?(n.created_at.to_date)}.should be_true
    end
  end

  describe "archive_months" do
    it "should return array of unique year and months for published pages and in decending order" do
      NewsIndex.archive_months.should have(3).items
    
      NewsIndex.archive_months.first[:year].should == 2009
      NewsIndex.archive_months.first[:month].should == 2

      NewsIndex.archive_months.second[:year].should == 2009
      NewsIndex.archive_months.second[:month].should == 1

      NewsIndex.archive_months.third[:year].should == 2008
      NewsIndex.archive_months.third[:month].should == 12
    end
  end
  
  describe "date_range_for_month" do
    it "should return nil with invalid year or month" do
      NewsIndex.date_range_for_month(2009, "feb").should == nil
      NewsIndex.date_range_for_month(2009, 0).should == nil
      NewsIndex.date_range_for_month(2009, 40).should == nil
    end
    it "should return a Range with valid year and month" do
      r = NewsIndex.date_range_for_month("2009", "01")
      r.should be_a(Range)
      r.begin.should == Date.new(2009,1,1)
      r.end.should == Date.new(2009,1,31)
    end
  end
    
end