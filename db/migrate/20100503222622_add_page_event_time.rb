class AddPageEventTime < ActiveRecord::Migration
  def self.up
    add_column :pages, :event_date, :datetime
  end

  def self.down
    remove_column :pages, :event_date
  end
end
