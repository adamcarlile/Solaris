class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.references :user
      t.column :event_type, :string
      t.column :eventable_id, :integer
      t.column :eventable_type, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
