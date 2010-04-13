class CreatePanels < ActiveRecord::Migration
  def self.up
    create_table :panels do |t|
      t.references :editable, :polymorphic => :true
      t.column :title, :string
      t.column :text, :text
      t.column :position, :integer
      t.column :image_file_name, :string
      t.column :image_content_type, :string
      t.column :image_file_size, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :panels
  end
end
