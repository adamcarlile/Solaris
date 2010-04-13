class CreatePublishableEvents < ActiveRecord::Migration
  def self.up
    # tracking the workflow history on publishable models
    create_table "publishable_events", :force => true do |t|
      t.timestamps
      t.integer :user_id # user who fired the event
      t.integer :assigned_user_id # might want to make a user responsible for next step in workflow
      t.integer :publishable_id
      t.string :publishable_type
      t.string :comment
      t.string :from_state
      t.string :to_state
    end
    
  end

  def self.down
    drop_table "publishable_events"
  end
end
