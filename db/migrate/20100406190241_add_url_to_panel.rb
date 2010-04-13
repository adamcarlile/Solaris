class AddUrlToPanel < ActiveRecord::Migration
  def self.up
    add_column :panels, :url, :string
  end

  def self.down
    remove_column :panels, :url
  end
end
