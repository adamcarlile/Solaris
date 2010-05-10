class AddEndDate < ActiveRecord::Migration
  def self.up
    add_column :pages, :event_end_date, :datetime
  end

  def self.down
    remove_column :pages, :event_end_date
  end
end
