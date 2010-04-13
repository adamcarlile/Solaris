class RenameImageAttachmentColumns < ActiveRecord::Migration
  def self.up
    rename_column "images", "image_file_name", "file_file_name"
    rename_column "images", "image_content_type", "file_content_type"
  end

  def self.down
    rename_column "images", "file_file_name", "image_file_name"
    rename_column "images", "file_content_type", "image_content_type"
  end
end
