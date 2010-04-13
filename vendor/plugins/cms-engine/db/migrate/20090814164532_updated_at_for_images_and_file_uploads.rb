class UpdatedAtForImagesAndFileUploads < ActiveRecord::Migration
  def self.up
    add_column "images", "updated_at", :datetime
    add_column "file_uploads", "updated_at", :datetime
  end

  def self.down
    remove_column "images", "updated_at"
    remove_column "file_uploads", "updated_at"
  end
end
