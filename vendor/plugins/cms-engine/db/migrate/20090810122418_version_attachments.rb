class VersionAttachments < ActiveRecord::Migration
  def self.up
    create_table "page_version_attachments" do |t|
      t.integer  "page_version_id"
      t.integer  "attachable_id"
      t.integer  "position"
      t.string   "attachable_type"
      t.string   "container"
      t.string   "size"
    end
  end

  def self.down
    drop_table "version_attachments"
  end
end
