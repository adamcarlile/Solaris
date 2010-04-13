require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  
  before(:all) do
    @global_nav = Factory.create(:top_level_folder)
    @image = Factory(:image)
    @file = Factory(:file_upload)
    User.destroy_all
    @user = Factory(:user)
  end

  describe "versioned?" do
    it "should be true for Page" do
      Page.versioned?.should be_true
    end
    it "should be false for some unversioned model" do
      User.versioned?.should be_false
    end
  end

  describe "is_versioned" do
    it "should set version_table_name to page_versions" do
      Page.version_table_name.should == 'page_versions'
    end
    it "should set version_foreign_key to page_id" do
      Page.version_foreign_key.should == 'page_id'
    end
    it "should define Page::Version class with correct versioned_class" do
      Page::Version.superclass.should == ActiveRecord::Base
      Page::Version.versioned_class.should == Page
    end
  end
  
  describe "has_changes_to_versioned_columns?" do
    before :each do
      @page = Factory(:page, :parent => @global_nav)
    end
    it "should be false where page has been reloaded and differs from latest version but no attributes have been changed" do
      @page = Factory(:page, :parent => @global_nav, :body => nil)
      @page.body = 'Changed body'
      @page.save
      # reload page, body will now be nil because updated body is only stored in version so far
      @page.reload
      # 
      @page.has_changes_to_versioned_columns?.should be_false
    end
  end
  
  describe "create_version?" do
    before :each do
      @page = Factory(:page, :parent => @global_nav)
    end
    it "should be false if there were no changes" do
      @page.create_version?.should be_false
    end
    it "should be false if changes were to non-versioned columns" do
      @page.created_at = @page.created_at - 1.day
      @page.create_version?.should be_false
    end
    it "should be true if there were changes to versioned columns" do
      @page.title = 'Modified title'
      @page.create_version?.should be_true
    end
    it "should be true if an attachment has been changed" do
      @page.stubs(:attachments_changed?).returns(true)
      @page.create_version?.should be_true
    end
  end
  
  describe "attachments_changed?" do
    before :each do
      @page = Factory(:page, :parent => @global_nav)
    end
    it "should be true if an attachment is added" do
      @page.attachments.build(:attachable => @image)
      @page.attachments_changed?.should be_true
    end
    it "should be false if current page's attachments are different to latest version but they haven't been changed" do
      @page.attachments.build(:attachable => @image)
      @page.save
      @page.reload
      # attachments will differ from latest version but since none have been changed since loading the page 
      # they won't be versioned, if a new version is created it'll just have the same attachments as previous version
      @page.attachments_changed?.should be_false
    end
    it "should be false if attachments are the same as those in the latest version" do
      # when modifying attachments we're working with a collection of unsaved records but comparing with
      # the latest version's attachments where they are saved
      
      # Force latest version to have an attachment to bypass attachments_changed?
      @page.latest_version.attachments.create(:attachable => @image, :position => 1)
      @page.latest_version.attachments.length.should == 1

      @page.reload

      @page.attachments.build(:attachable => @image, :position => 1)

      @page.attachments_changed?.should be_false
    end
  
    it "should be true if the position of an attachment has changed" do
      @page.latest_version.attachments.create(:attachable => @image, :position => 1)
      @page.latest_version.attachments.create(:attachable => @file, :position => 2)

      @page.reload
      @page.build_attachments_from_version(@page.latest_version)

      # reorder the attachments
      @page.attachments.first.position = 2
      @page.attachments.last.position = 1
      @page.attachments_changed?.should be_true
    end
    
  end
  
  describe "destroy_attachment" do
    before :each do
      @page = Factory(:page, :parent => @global_nav)
    end
    it "should make attachments_changed? true" do
      @page.attachments.create!(:attachable => @image)
      @page.attachments.count.should == 1
      @page.destroy_attachment(@page.attachments.first)
      @page.attachments_changed?.should be_true
    end
  end
  
  describe "attributes_for_version" do
    it "should have the same keys as versioned columns" do
      @page = Factory(:page, :parent => @global_nav)
      @page.attributes_for_version.keys.sort.should == Page.versioned_columns.sort
    end
  end

  describe "latest_version" do
    it "should be nil for new page record"  do
      Page.new.latest_version.should be_nil
    end
    it "should be a Page::Version instance for existing record" do
      @page = Factory(:page, :parent => @global_nav)
      @page.latest_version.page.should == @page
    end
    it "should be the version with the highest version number" do
      @page = Factory(:page, :parent => @global_nav)
      @page.title = 'New title'
      @page.save
      @page.latest_version.version.should == 2
    end
  end
  
  describe "build_new_version" do
    it "should be a Page::Version instance with the page as its versioned object" do
      @page = Factory(:page, :parent => @global_nav)
      @version = @page.build_new_version
      @version.class.should == Page::Version
      @version.page.should == @page
    end
    it "should have a version number of 1 if page is a new record" do
      @page = Page.new
      @page.build_new_version.version.should == 1
    end
    it "should have a version number of 2 if page is not a new record" do
      @page = Factory(:page, :parent => @global_nav)
      @page.build_new_version.version.should == 2
    end
  end

  describe "save_without_versioning" do
    it "should save page normally" do
      @page = Factory(:page, :parent => @global_nav)
      @page.title = 'New title'
      @page.save_without_versioning
      @page.reload
      @page.title.should == 'New title'
    end
  end
  
  describe "newly created page" do
    before :each do
      @page = Factory.build(:page, :parent => @global_nav)
      @page.save
    end
    it "should have a version number of 1" do
      @page.version.should == 1
    end
    it "should have a 1 version" do
      @page.versions.count.should == 1
    end
  end
  
  describe "save" do
    before :each do
      @page = Factory.build(:page, :parent => @global_nav)
      @page.save
    end
    describe "when create_version? is true" do
      before :each do
        @old_updated_at = @page.updated_at
        @page.stubs(:create_version?).returns(true)
        @old_version_count = @page.versions.count
        @old_title = @page.title
        @page.title = 'Updated title'
        sleep 2 # so timestamps change
        @page.save
      end
      it "should create a new version" do
        @page.versions.count.should == @old_version_count + 1
      end
      it "should not modify page record's content fields" do
        Page.find(@page.id).title.should == @old_title
      end
      it "should update page's timestamps" do
        Page.find(@page.id).updated_at.should > @old_updated_at
      end
    end
    describe "with changes to non-versioned attributes" do
      it "should update the page's non-versioned attributes while creating a new version" do
        @new_parent = Factory(:page, :parent => @global_nav)
        
        @page = Factory(:page, :parent => @global_nav)
        @page.versions.count.should == 1
        @page.reload

        @page.attributes = {:title => 'Updated title', :parent_id => @new_parent.id}
        @page.save
        @page.reload

        @page.versions.count.should == 2
        @page.latest_version.title.should == 'Updated title'
        @page.parent_id.should == @new_parent.id
      end
      it "should update the page's non-versioned attributes when not creating a new version " do
        @page = Factory(:page, :parent => @global_nav)
        @page.versions.count.should == 1
        @page.update_attribute(:position, 99)
        @page.position.should == 99
      end
    end
    describe "when create_version? is false" do
      it "should save normally without versioning" do
        @page.stubs(:create_version?).returns(false)
        @page.expects(:save_without_versioning).once
        @page.save
      end
    end
  end                  

  describe "build_version" do
    before :each do
      @page = Factory(:page, :parent => @global_nav)
      @old_version_number = @page.latest_version.version
      @version = @page.build_new_version
    end
    it "should create version with attributes set on the page" do
      @page.versioned_columns.each do |column_name|
        @version.attributes[column_name].should == @page.attributes[column_name]
      end
    end
    it "should create version incremented version number" do
      @version.version.should == (@old_version_number + 1)
    end
    it "for saved record, should combine attributes from latest version with changed columns" do
      @page = Factory(:page, :parent => @global_nav, :title => 'title 1', :body => 'body 1')
      @page.versions.count.should == 1

      @page.title = 'title 2'
      @page.body = 'body 2'
      @page.save
      @page.versions.count.should == 2
      
      @page.reload
      @page.body = 'body 3'
      
      # only one attribute has changed so rather than copy all the current attributes to a new version,
      # which would include the current published attributes and this change,
      # we should apply this change on top of the latest version's attributes
      
      @page.save
      @page.versions.count.should == 3
      
      @page.latest_version.title.should == 'title 2'
      @page.latest_version.body.should == 'body 3'
    end
  end
  
  describe "published_version" do
    it "should return a version with the same version number as the page's version number" do
      @page = Factory(:page, :parent => @global_nav)
      @page.published_version.version.should == @page.version
    end
  end
  
  describe "load_attributes_from_version" do
    it "should replace current page's versioned attributes with those from supplied version number" do
      @page = Factory(:page, :parent => @global_nav, :body => 'v1 body')
      @page.body = 'v2 body'
      @page.save
      @page.reload
      @page.body.should == 'v1 body'
      @page.load_attributes_from_version(2)
      @page.body.should == 'v2 body'
    end
  end

  describe "publish_latest_version" do
    before :each do
      @page = Factory(:page, :parent => @global_nav, :body => 'v1 body')
    end
    it "should update the page with attributes from the latest version" do
      @page.body = 'v2 body'
      @page.save
      @page.publish_latest_version
      @page.reload
      @page.body.should == 'v2 body'
    end
    it "should update page's version number" do
      @page.version.should == 1
      @page.body = 'Updated body'
      @page.save
      @page.publish_latest_version
      @page.version.should == 2
    end
    it "should copy attachments from version" do
      @page.attachments.build :attachable => @image
      @page.save
      @page.reload
      @page.attachments.should be_empty
      @page.publish_latest_version
      @page.attachments.count.should == 1
      @page.attachments.first.attachable.should == @image
    end
    it "should clear attachments if the latest version has none" do
      Attachment.create(:page => @page, :attachable => @image)
      @page.reload
      @page.attachments.count.should == 1

      @latest_version = @page.latest_version
      @latest_version.attachments.each &:destroy
      @latest_version.attachments.clear
      @latest_version.attachments.count.should == 0

      @page.publish_latest_version
      @page.attachments.should be_empty
      @page.attachments.count.should == 0
    end
  end
  
  describe "has_unpublished_changes?" do
    before :each do
      @page = Factory(:page, :parent => @global_nav)
    end
    it "should be false if the latest version is published already" do
      @page.has_unpublished_changes?.should be_false
    end
    it "should be true if the page has versions newer than the currently published version" do
      @page.title = 'New title'
      @page.save
      @page.has_unpublished_changes?.should be_true
    end
  end
  
  describe "version_comment" do
    it "should be stored in version when updating page" do
      @page = Factory(:page, :parent => @global_nav)
      @page.title = 'New title'
      @page.version_comment = 'The version comment'
      @page.save
      @page.latest_version.version_comment.should == 'The version comment'
    end
  end
  
  describe "destroy" do
    it "should also destroy versions" do
      Page::Version.delete_all
      Page::Version.count.should == 0
      @page = Factory(:page, :parent => @global_nav)
      @page.title = 'New title'
      @page.save
      Page::Version.count.should == 2
      @page.destroy
      Page::Version.count.should == 0
    end
  end

  describe "copy_attributes" do
    before :each do
      @page = Factory(:page, :parent => @global_nav)
      @page.attachments.build(:attachable => @image)
      @page.attachments.build(:attachable => @file)
      @version = Page::Version.new
    end
    it "should copy attributes and attachments from @page to version" do
      @page.title = 'New title'
      @page.copy_attributes(@page, @version)
      @version.title.should == @page.title
      @version.attachments.map(&:attachable).should == @page.attachments.map(&:attachable)
      @version.attachments.length.should == 2
    end
    it "should not copy attachmented marked for destruction to version" do
      @page.attachments.first.mark_for_destruction
      @page.copy_attributes(@page, @version)
      @version.attachments.length.should == 1
    end
    it "should copy attributes from version to @page" do
      @version.title = 'Version title'
      @version.body = 'Version body'
      @page.copy_attributes(@version, @page)
      @page.title.should == @version.title
      @page.body.should == @version.body
    end
    it "should clear @page's attachments if version has no attachments" do
      @page.copy_attributes(@version, @page)
      @page.attachments.should be_empty
    end
    it "should replace @page's attachments with the versions" do
      @page.attachments.clear
      @page.attachments.build(:attachable => @image)
      @version.attachments.build(:attachable => @file)
      @page.save
      @version.save
      @page.copy_attributes(@version, @page)
      @page.attachments.length.should == 1
      @page.attachments.first.attachable.should == @file
    end
  end
  
  describe "attachments" do
    before :each do
      # v1, no attachments
      @page = Factory(:page, :parent => @global_nav)
      # v2, 1 attachment
      @page.attachments.build(:attachable => @image)
      @page.save
      # v3, 2 attachments
      @page.attachments.build(:attachable => @file)
      @page.save
      @page.reload
    end

    it "should return the attachments normally if now viewing a different version" do
      @page.attachments.should be_empty
    end
    it "should return the latest version's attachments if viewing the latest version" do
      @page.preview_latest_version
      @page.attachments.length.should == 2
    end
    it "should return the correct version's attachments if viewing a specific version" do
      @page.load_attributes_from_version(2)
      @page.attachments.length.should == 1
    end
    it "should return the correct version's attachments after publishing latest version" do
      @page.publish_latest_version
      @page.attachments.length.should == 2
    end
  end

  describe "attachments_attributes=" do
    before :all do
      @valid_attachments_attributes = [
        {:attachable_type => "Image", :attachable_id => @image.id.to_s, :position => 2},
        {:attachable_type => "FileUpload", :attachable_id => @file.id.to_s, :position => 1}
      ]
    end
    before :each do
      @page = Factory(:page, :parent => @global_nav)
    end

    it "should raise an error if argument isn't an array" do
      lambda { 
        @page.attachments_attributes = 'foo'
      }.should raise_error(RuntimeError) 
    end

    it "should build a collection of attachments given valid attributes" do
      @page.attachments_attributes = @valid_attachments_attributes
      @page.attachments.length.should == 2
    end
    
    it "should give all attachments the correct position" do
      @page.attachments_attributes = @valid_attachments_attributes
      @page.attachments.first.attachable.should == @image
      @page.attachments.first.position.should == 2
    end
    
    it "should update existing attachments rather than building new ones" do
      @page.attachments.count.should == 0
      @page.attachments.build(:attachable => @image, :position => 1)
      @page.save
      @page.publish_latest_version
      @page.attachments.count.should == 1

      @page.attachments_attributes = @valid_attachments_attributes
      
      attachables = @page.attachments.map(&:attachable)
      attachables.length.should == 2
      attachables.should include(@image)
      attachables.should include(@file)
    end

  end

  describe "revertable?" do
    before :each do
      @page = Factory(:page, :parent => @global_nav, :title => 'Title 1')
      @v1 = @page.versions.first

      @page.title = 'Title 2'
      @page.save
      @page.publish_latest_version
      @v2 = @page.published_version
      
      @page.title = 'Title 3'
      @page.save
      @v3 = @page.latest_version
      @page.publish_latest_version
      
      @page.title = 'Title 4'
      @page.save
      @v4 = @page.latest_version
      
    end    
    it "should be false for latest version" do
      @v4.revertable?.should be_false
    end
    it "should be false for the published version" do
      @v4.revertable?.should be_false
    end
    it "should be true for an older version that isn't published" do
      @v1.revertable?.should be_true
    end
  end

  describe "revert_to_version" do
    before :each do
      @page = Factory(:page, :parent => @global_nav, :title => 'Title 1')
      @page.title = 'Title 2'
      @page.save
      @page.title = 'Title 3'
      @page.save
      @page.publish_latest_version
    end    
    it "should be false if version isn't revertable" do
      @version = @page.versions.first
      Page::Version.any_instance.stubs(:revertable?).returns(false)
      @page.revert_to_version(1).should be_false
    end
    it "should create a new version with the chosen version's attributes" do
      @page.revert_to_version(1)
      @page.versions.count.should == 4
      @page.latest_version.title.should == 'Title 1'
    end
  end

  describe "user of new version" do
    before :each do
      @page = Factory.build(:page, :parent => @global_nav, :title => 'Title 1')
      @page.current_user = @user
      @page.save
    end
    it "should be the page's current user when creating page" do
      @page.latest_version.user.should == @user
    end
    it "should be the page's current user when updating page" do
      @page.title = 'Title 2'
      @page.current_user = @user
      @page.save
      @page.latest_version.user.should == @user
    end
    it "should be nil if the page has no current user when updating" do
      @page.current_user = nil
      @page.title = 'Title 2'
      @page.save
      @page.latest_version.user.should be_nil
    end
  end

  describe "callbacks" do
    before :each do
      @page = Factory.build(:page, :parent => @global_nav, :title => 'Title 1')
    end

    describe "after_version_created" do
      it "should be called on page" do
        @page.expects(:after_version_created).once
        @page.title = 'Title 2'
        @page.save
      end
    end
  end

  describe "contributors" do
    before :all do
      @writer1 = Factory(:user)
      #@writer1.roles = [Role.writer]
      @writer2 = Factory(:user)
      #@writer2.roles = [Role.writer]
    end
    
    it "should only single user if that user created the page and the first version" do
      @page = Factory(:page, :parent => @global_nav, :title => 'Title 1', :current_user => @user)
      @page.contributors.length.should == 1
      @page.contributors.should include(@user)
    end
    
    it "should contain creator and users that created versions" do
      @page = Factory(:page, :parent => @global_nav, :title => 'Title 1', :current_user => @user)
      @page.current_user = @writer1
      @page.title = 'Title 2'
      @page.save

      @page.current_user = @writer2
      @page.title = 'Title 3'
      @page.save

      @page.current_user = @writer2
      @page.title = 'Title 4'
      @page.save
      
      @page.versions.count.should == 4
      @page.contributors.length.should == 3
      @page.contributors.should include(@user)
      @page.contributors.should include(@writer1)
      @page.contributors.should include(@writer2)
    end

  end

end
