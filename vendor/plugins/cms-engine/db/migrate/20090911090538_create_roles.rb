class CreateRoles < ActiveRecord::Migration
  def self.up

    create_table "roles", :force => true do |t|
      t.string  "name"
      t.string "description"
    end

    create_table "roles_users", :force => true do |t|
      t.integer :user_id, :role_id
    end
    remove_column "roles_users", :id

  end

  def self.down
    drop_table "roles"
    drop_table "roles_users"
  end
end
