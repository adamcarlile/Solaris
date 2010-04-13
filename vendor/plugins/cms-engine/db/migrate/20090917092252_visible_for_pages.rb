class VisibleForPages < ActiveRecord::Migration
  def self.up
    add_column "pages", "visible", :boolean, :default => false
  end

  def self.down
    remove_column "pages", "visible"
  end
end
