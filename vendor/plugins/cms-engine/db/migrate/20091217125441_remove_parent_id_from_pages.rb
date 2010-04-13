class RemoveParentIdFromPages < ActiveRecord::Migration
  def self.up
    remove_column :pages, :parent_id
  end

  def self.down
  end
end
