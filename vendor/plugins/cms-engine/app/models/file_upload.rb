class FileUpload < ActiveRecord::Base

  ALLOWED_FILE_UPLOAD_EXTENSIONS = %w(jpg jpeg pdf doc xls png gif)

  has_attached_file :file, :path => ":rails_root/upload/:rails_env/files/:id/:basename.:extension"

  acts_as_taggable
  is_userstamped

  validates_attachment_presence :file, :message => 'not uploaded'
  #validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/gif', 'image/png']

  before_create :set_title_if_necessary

  def set_title_if_necessary
    if title.blank?
      self.title = file_name
    end
  end
  
  def file_name
    file_file_name
  end

  def permenant_url
    "/assets/files/#{id}"
  end

  #
  # Versioning
  #

  is_versioned :versioned_columns => %w(title file file_file_name tag_list) do
    has_attached_file :file, :path => ":rails_root/upload/:rails_env/file_versions/:id/:basename.:extension"
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

    
  #
  # Attachable
  #

  is_attachable
  
  def thumb_url(size = 'large')
    "/cms/images/admin/filetypes/#{size}/#{file_ext.downcase}.png"
  end

  def file_ext
    File.extname(file_file_name).gsub(".","")
  end

  def details
    file.content_type
  end
  


  def editable_by?(user)
    user.has_role?(:writer)
  end
  def publishable_by?(user)
    user.has_role?(:editor)
  end
  
end
