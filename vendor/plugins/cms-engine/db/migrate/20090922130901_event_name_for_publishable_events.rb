class EventNameForPublishableEvents < ActiveRecord::Migration
  def self.up
    add_column "publishable_events", "event_name", :string
  end

  def self.down
    remove_column "publishable_events", "event_name"
  end
end
