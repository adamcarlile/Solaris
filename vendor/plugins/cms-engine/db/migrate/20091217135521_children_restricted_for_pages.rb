class ChildrenRestrictedForPages < ActiveRecord::Migration
  def self.up
    add_column "pages", "children_restricted", :boolean, :default => false
  end

  def self.down
    remove_column "pages", "children_restricted"
  end
end
