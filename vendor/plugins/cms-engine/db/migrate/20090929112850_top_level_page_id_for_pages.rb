class TopLevelPageIdForPages < ActiveRecord::Migration
  def self.up
    # cache which top level parent a page belongs to so avoid accessing ancestors when filtering pages by user's page specific permissions
    add_column "pages", "top_level_page_id", :integer
  end

  def self.down
    remove_column "pages", "top_level_page_id"
  end
end
