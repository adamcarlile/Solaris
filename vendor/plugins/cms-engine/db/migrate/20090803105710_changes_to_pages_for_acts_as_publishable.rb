class ChangesToPagesForActsAsPublishable < ActiveRecord::Migration
  def self.up
    remove_column "pages", "published"
    remove_column "pages", "publish_date"

    add_column "pages", "creator_user_id", :integer

    add_column "pages", "state", :string

    add_column "pages", "publish_from", :datetime
    add_column "pages", "publish_to", :datetime
  end

  def self.down
    remove_column "pages", "creator_user_id"
    add_column "pages", "published", :boolean, :default => false
    remove_column "pages", "state"
    remove_column "pages", "publish_to"
    remove_column "pages", "publish_from"
    add_column "pages", "publish_date", :datetime
  end
end
