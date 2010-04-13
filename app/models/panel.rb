class Panel < ActiveRecord::Base
  
  belongs_to :editable, :polymorphic => true
  belongs_to :page
  validates_presence_of :title
  validates_presence_of :text
  validates_presence_of :url
  
  default_scope :order => 'position'
  
  has_attached_file :image,
    :url =>  "/upload/:rails_env/panels/:id/:style_:basename.:extension",
    :path => ":rails_root/public/upload/:rails_env/panels/:id/:style_:basename.:extension",
    :styles => {
      :main => "300x131#",
      :thumb  => "64x64#" }
    
end
