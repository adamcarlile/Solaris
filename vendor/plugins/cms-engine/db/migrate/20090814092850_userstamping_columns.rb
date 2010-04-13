class UserstampingColumns < ActiveRecord::Migration
  def self.up
    
    add_column "pages", "created_by_id", :integer
    add_column "pages", "updated_by_id", :integer
    
    add_column "images", "created_by_id", :integer
    add_column "images", "updated_by_id", :integer
    
    add_column "file_uploads", "created_by_id", :integer
    add_column "file_uploads", "updated_by_id", :integer
    
  end

  def self.down
    remove_column "pages", "created_by"
    remove_column "pages", "updated_by"
    remove_column "images", "created_by"
    remove_column "images", "updated_by"
    remove_column "file_uploads", "created_by"
    remove_column "file_uploads", "updated_by"
  end
end
