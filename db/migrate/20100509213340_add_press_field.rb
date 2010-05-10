class AddPressField < ActiveRecord::Migration
  def self.up
    add_column :pages, :press_info, :text
  end

  def self.down
    remove_column :pages, :press_info
  end
end
