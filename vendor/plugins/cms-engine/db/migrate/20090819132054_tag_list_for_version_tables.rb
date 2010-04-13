class TagListForVersionTables < ActiveRecord::Migration
  def self.up
    add_column "page_versions", "tag_list", :string
    add_column "image_versions", "tag_list", :string
    add_column "file_upload_versions", "tag_list", :string
  end

  def self.down
    remove_column "page_versions", "tag_list"
    remove_column "image_versions", "tag_list"
    remove_column "file_upload_versions", "tag_list"
  end
end
