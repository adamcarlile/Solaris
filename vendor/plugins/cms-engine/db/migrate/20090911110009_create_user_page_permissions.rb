class CreateUserPagePermissions < ActiveRecord::Migration
  def self.up

    create_table "user_page_permissions", :force => true do |t|
      t.integer :user_id, :page_id
      t.boolean :edit, :default => false
      t.boolean :publish, :default => false
    end
    
  end

  def self.down
  end
end
