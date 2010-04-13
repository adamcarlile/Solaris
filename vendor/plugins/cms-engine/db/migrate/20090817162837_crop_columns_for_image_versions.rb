class CropColumnsForImageVersions < ActiveRecord::Migration
  def self.up
    add_column "image_versions", "resize", :float
    add_column "image_versions", "crop_w", :integer
    add_column "image_versions", "crop_h", :integer
    add_column "image_versions", "crop_x", :integer
    add_column "image_versions", "crop_y", :integer
  end

  def self.down
    remove_column "image_versions", "resize"
    remove_column "image_versions", "crop_w"
    remove_column "image_versions", "crop_h"
    remove_column "image_versions", "crop_x"
    remove_column "image_versions", "crop_y"
  end
end
