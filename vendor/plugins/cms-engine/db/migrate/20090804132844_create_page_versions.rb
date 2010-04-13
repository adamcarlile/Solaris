class CreatePageVersions < ActiveRecord::Migration
  def self.up

    create_table "page_versions", :force => true do |t|
      # Information about the version
      t.integer  "page_id"
      t.integer  "user_id" # creator of the version, not original page
      t.integer  "version"
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "version_comment"
      # Versioned columns
      t.datetime "publish_from"
      t.datetime "publish_to"
      t.string   "title"
      t.string   "meta_title"
      t.string   "meta_description"
      t.string   "meta_keywords"
      t.string   "nav_title"
      t.string   "url"
      t.text     "intro"
      t.text     "body"
    end

    add_column "pages", "version", :integer
  end

  def self.down
    drop_table "page_versions"
    remove_column "pages", "version"
  end
end
