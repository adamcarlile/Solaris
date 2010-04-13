class CreateFileUploadVersions < ActiveRecord::Migration
  def self.up
    create_table "file_upload_versions", :force => true do |t|
      # Information about the version
      t.integer  "file_upload_id"
      t.integer  "user_id" # creator of the version
      t.integer  "version"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "version_comment"
      # Versioned columns
      t.string   "title"
      t.string   "file_file_name"
      t.string   "file_content_type"
      t.string   "title"
      t.string   "file_file_name"
      t.string   "file_content_type"
    end

    add_column "file_uploads", "version", :integer
  end

  def self.down
    drop_table "file_upload_versions"
    remove_column "file_uploads", "version"
  end
end
