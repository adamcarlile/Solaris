require File.dirname(__FILE__) + '/../spec_helper'

describe Page do

  before(:all) do
    @global_nav = Factory.create(:top_level_folder)
  end
                             
  describe "publish!" do
    it "should fail if page is already published" do
      @page = Factory(:published_page)
      lambda {
        @page.publish!
      }.should raise_error(StateMachine::InvalidTransition)
    end
    it "should set state to 'published' for draft page" do
      @page = Factory(:page, :state => 'draft')
      @page.versions.count.should == 1
      @page.publish!
      @page.state.should == 'published'
      @page.versions.count.should == 1
    end

    it "should set visible to true for draft page" do
      @page = Factory(:page, :state => 'draft')
      @page.visible?.should be_false
      @page.publish!
      puts @page.attributes.inspect
      @page.visible?.should be_true
    end

  end

  describe "unpublish!" do
    before(:all) do
      @page = Factory(:published_page)
      @page.unpublish!
    end
    it "should set visible to false" do
      @page.visible.should be_false
    end
    it "should set state to draft" do
      @page.state_name.should == :draft
      @page.state.should == 'draft'
    end
  end

end
