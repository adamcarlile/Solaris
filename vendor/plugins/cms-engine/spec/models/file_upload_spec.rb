require File.dirname(__FILE__) + '/../spec_helper'

module FileUploadSpecHelper
  def get_file_fixture(filename = 'test.xls')
    File.open( File.join(CmsEngine::ROOT,'spec/fixtures/files',filename))
  end
end

describe FileUpload do
  include FileUploadSpecHelper

  before(:each) do
  end

  it "should have a working factory" do
    file_upload = Factory.build(:file_upload)
    file_upload.should be_valid
    file_upload.save
    file_upload.file.exists?.should be_true
  end

  describe "validation" do
    it "should not be valid without a file" do
      FileUpload.new.should be_invalid
    end

    it "should be valid if image is an allowed type" do
      FileUpload.new(:file => get_file_fixture('test.xls')).should be_valid
    end
  end

  describe "newly created file" do
    before(:each) do
      @file = Factory(:file_upload)
    end
    it "should have 1 version" do
      @file.versions.count.should == 1
    end
  end
  
  describe "save" do
    before(:each) do
      @file = Factory(:file_upload)
    end
    it "should create a new version if title changes" do
      @file.title = 'New title'
      @file.save
      @file.versions.count.should == 2
    end
    it "should create a new version if file changes" do
      @file.file = get_file_fixture('test2.xls')
      @file.save
      @file.versions.count.should == 2
      @file.latest_version.file.exists?.should be_true
      @file.latest_version.file_file_name.should == 'test2.xls'
    end
    it "should not create a new version if there are no changes" do
      @file.save
      @file.versions.count.should == 1
    end
  end
  
  describe "create_version?" do
    before(:each) do
      @file = Factory(:file_upload)
    end
    it "should be true if file changes" do
      @file.file = get_file_fixture('test2.xls')
      @file.create_version?.should be_true
    end
  end

end




