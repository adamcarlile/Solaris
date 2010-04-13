require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  
  before(:all) do
    @global_nav = Factory.create(:top_level_folder)
    Tagging.destroy_all
    Tag.destroy_all
  end

  describe "has_changes_to_versioned_columns?" do
    before :all do
      @page = Factory.create(:page, :parent => @global_nav, :tag_list => 'one two')
    end
    it "should be false for new page" do
      @page.has_changes_to_versioned_columns?.should be_false
    end
    it "should be true if tag_list has changed" do
      @page.tag_list = 'one two three'
      @page.has_changes_to_versioned_columns?.should be_true
    end
  end
  
  describe "create with tag list" do
    before :all do
      @page = Factory.create(:page, :parent => @global_nav, :tag_list => 'one two')
    end
    it "should create taggings" do
      @page.taggings.count.should == 2
    end
    it "should copy tag list to initial version" do
      @page.versions.first.tag_list.should == 'one two'
    end
  end

  describe "save" do
    before :all do
      @page = Factory.create(:page, :parent => @global_nav, :tag_list => 'one')
    end
    describe "with modified tag list" do
      before :all do
        @page.tag_list = 'three four'
        @page.save
      end
      it "should save tag list to new version" do
        @page.latest_version.tag_list.should == 'three four'
      end
      it "should not modify taggings" do
        @page.tags.length.should == 1
        @page.tags.first.name.should == 'one'
      end
    end
  end
  
  describe "publish_latest_version" do
    before :all do
      @page = Factory.create(:page, :parent => @global_nav, :tag_list => 'one two')
      @page.tag_list = 'two three'
      @page.save
      @page.reload
    end
    
    it "should update page's taggings according to verion's tag list" do
      @page.tag_list.should == 'one two'
      @page.publish_latest_version
      updated_tags = @page.tags.map(&:name)
      updated_tags.should have(2).items
      updated_tags.should include('two')
      updated_tags.should include('three')
    end

  end

end
