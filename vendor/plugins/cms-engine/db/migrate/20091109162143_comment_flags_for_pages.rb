class CommentFlagsForPages < ActiveRecord::Migration
  def self.up
    add_column "pages", "show_comments", :boolean, :default => true
    add_column "pages", "allow_new_comments", :boolean, :default => true
  end

  def self.down
    remove_column "pages", "show_comments"
    remove_column "pages", "allow_new_comments"
  end
end
