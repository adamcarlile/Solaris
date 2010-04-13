class Image < ActiveRecord::Base

  attachment_options = {
    :url =>                   "/upload/:rails_env/images/:id/:style_:basename.:extension",
    :path => ":rails_root/public/upload/:rails_env/images/:id/:style_:basename.:extension",
    :styles => { 
      :thumb   => "80x80#", 
      :small   => ">100x100#",
      :medium  => "140x140>",
      :large   => "290x290>",
      :tocrop  => "650x650>", # this version acts as original file for loading into the flash cropping editor
      :cropped => "650x650#"  # the default cropped image until user edits crop settings which will replace just this file with new one based of the "tocrop" version
    }
  }
  version_attachment_options = attachment_options.merge({
    :url =>                   "/upload/:rails_env/image_versions/:id/:style_:basename.:extension",
    :path => ":rails_root/public/upload/:rails_env/image_versions/:id/:style_:basename.:extension"
  })

  has_attached_file :file, attachment_options

  validates_attachment_presence :file, :message => 'not uploaded'
  validates_attachment_content_type :file, :content_type => ['image/jpeg', 'image/gif', 'image/png']

  is_userstamped
  acts_as_taggable

  is_versioned :versioned_columns => %w(title file file_file_name resize crop_w crop_h crop_x crop_y tag_list) do
    has_attached_file :file, version_attachment_options
  end
                     
  def clear_changes
    @new_tag_list = nil
    file.dirty = false
    super
  end

  # If a version is being previewed, get the attachment from the version instead
  alias_method :original_file, :file
  def file
    viewing_version ? viewing_version.file :  original_file
  end

  def permenant_url(version = 'original')
    "/assets/images/#{id}-#{version}"
  end

  SIZES = %w(thumb small medium large cropped)

  after_create :store_image_dimensions_for_cropping
  
  # Sets the defaults for resize and crop settings based on the image uploaded
  # These will get overwritten and the cropped size re-created if cropping tool is used
  def store_image_dimensions_for_cropping
    save_attached_files # make sure Paperclip stores the files before this callback is executed
    if file.exists?
      img = ThumbMagick::Image.new(file.path('tocrop'))
      w,h = img.dimensions
      self.resize = 1
      self.crop_w = w
      self.crop_h = h
      self.crop_x = self.crop_y = 0
      save_without_versioning
      latest_version.update_attributes(:resize => resize, :crop_w => crop_w, :crop_h => crop_h, :crop_x => 0, :crop_y => 0)
    end
  end

  # Use resize_w,resize_h,crop_x,crop_y,crop_w and crop_h to recreate "cropped" image version
  def recreate_cropped_image
    if file.exists?
      img = ThumbMagick::Image.new(file.path('tocrop'))
      img.
        thumbnail("#{ (resize * 100).to_i }%").
        crop("#{crop_w}x#{crop_h}", crop_x, crop_y).
        write(file.path('cropped'))
    end    
  end
  
  def publish_latest_version
    super
    recreate_cropped_image
  end


  before_validation_on_create :set_title_if_necessary

  def set_title_if_necessary
    if title.blank?
      self.title = file_file_name
    end
  end
  
  def file_name
    file_file_name
  end


  #
  # Attachable
  #
  
  is_attachable

  def thumb_url(size = 'thumb')
    file.url(size)
  end
    
  def details
    file_file_name
  end



  def editable_by?(user)
    user.has_role?(:writer)
  end
  def publishable_by?(user)
    user.has_role?(:editor)
  end
  
end
