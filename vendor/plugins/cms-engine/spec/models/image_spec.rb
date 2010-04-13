require File.dirname(__FILE__) + '/../spec_helper'

module ImageSpecHelper
  def get_image_fixture(filename = 'mm.jpg')
    File.open( File.join(CmsEngine::ROOT,'spec/fixtures/images',filename))
  end
end

describe Image do
  include ImageSpecHelper

  before(:each) do
    Image.destroy_all
  end                   
  
  describe "validation" do
    it "should not be valid without an image file" do
      Image.new.should be_invalid
    end

    it "should be invalid if image is the wrong type of file" do
      Image.new(:file => get_image_fixture('mm.pdf')).should be_invalid
    end
  
    it "should be valid if image is an allowed type" do
      Image.new(:file => get_image_fixture('mm.jpg')).should be_valid
    end
  end
  
  describe "create" do
    it "should set the title to image's filename if its blank" do
      @image = Image.create!(:file => get_image_fixture('mm.jpg'))
      @image.title.should == 'mm.jpg'
    end
    it "should use the supplied title if there is one, rather than image filename" do
      @image = Image.create!(:title => 'Test', :file => get_image_fixture('mm.jpg'))
      @image.title.should == 'Test'
    end
    it "should save the dimensions of the image for cropping purposes" do
      @image = Image.create!(:file => get_image_fixture('mm.jpg'))
      @image.reload
      @image.crop_w.should == 150
      @image.crop_h.should == 217
      @image.latest_version.crop_w.should == 150
      @image.latest_version.crop_h.should == 217
    end
  end
              
  describe "newly created image's version" do
    before :each do
      @image = Image.create!(:file => get_image_fixture('mm.jpg'))
    end
    it "should exist" do
     @image.versions.count.should == 1
    end
    it "should have the title from the image's filename" do
      @image.title.should == 'mm.jpg'
      @image.latest_version.title.should == 'mm.jpg'
    end
    it "should have its own image file" do
      @image.latest_version.file.exists?.should be_true
    end
    it "should have a different file to that of the original image" do
      @image.latest_version.file.path.should_not == @image.file.path
    end
  end
  
  describe "updated image's version when only title changed" do
    before(:each) do
      @image = Image.create!(:file => get_image_fixture('mm.jpg'))
      @image.title = 'Test'
      @image.save
    end
    it "should have an image file" do
      @image.latest_version.file.exists?.should be_true
    end
    it "should have a different file from first version" do
      @image.versions(true)
      @image.versions.first.file.path.should_not == @image.versions.last.file.path
    end
  end

  describe "updated image's version when image has changed" do
    before(:each) do
      @image = Image.create!(:file => get_image_fixture('mm.jpg'))
      @image.file = get_image_fixture('rails.png')
      @image.save
    end
    it "should have an image file" do
      @image.latest_version.file.exists?.should be_true
    end
    it "should have a different file from first version" do
      @image.versions(true)
      @image.versions.first.file.path.should_not == @image.versions.last.file.path
    end
  end
      
  describe "updating" do
    before(:each) do
      @image = Image.create!(:file => get_image_fixture('mm.jpg'))
    end
    it "should leave the original image intact" do
      @image.file = get_image_fixture('rails.png')
      @image.save
      @image = Image.find(@image.id)
      @image.file.exists?.should be_true
      @image.file_file_name.should == 'mm.jpg'
      @image.file.exists?.should be_true
    end
    it "should create a new version" do
      @image.file = get_image_fixture('rails.png')
      @image.save
      @image.versions.count.should == 2
    end
  end
  
  describe "publish_latest_version" do
    it "should update the current image file correctly" do
      @image = Image.create!(:file => get_image_fixture('mm.jpg'))
      @image.file = get_image_fixture('rails.png')

      @image.save
      @image.versions.count.should == 2

      @image.latest_version.file.exists?.should be_true

      @image.publish_latest_version
      @image.file_file_name.should == 'rails.png'
      @image.file.exists?.should be_true
    end
    it "should update the image with crop settings from version" do
      @image = Image.create!(:file => get_image_fixture('mm.jpg'))
      @image.title = 'New title'
      @image.save
      @image.resize.should == 1
      @version = @image.latest_version
      @version.update_attributes(:crop_w => 20, :crop_h => 10)
    
      @image.versions.count.should == 2
    
      @image.latest_version.resize.should == 1
      @image.publish_latest_version
      @image.resize.should == 1
    
      img = ThumbMagick::Image.new(@image.file.path('cropped'))
      w,h = img.dimensions
      w.should == 20
      h.should == 10
    end
  end

end
