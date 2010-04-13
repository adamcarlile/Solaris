class CreateBanners < ActiveRecord::Migration
  def self.up
    create_table :banners do |t|
      t.column :name, :string
      t.column :url, :string
      t.column :position, :integer
      t.column :banner_file_name, :string  
      t.column :banner_content_type, :string  
      t.column :banner_file_size, :integer  
      t.column :banner_updated_at, :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :banners
  end
end
