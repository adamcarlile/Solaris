class Banner < ActiveRecord::Base
  default_scope :order => 'position'  
  
  acts_as_list
  
  attachment_options = {
     :url => "/upload/:rails_env/banners/:id/:style_:basename.:extension",
     :path => ":rails_root/public/upload/:rails_env/banners/:id/:style_:basename.:extension",
     :styles => { 
       :thumb   => "80x80#", 
       :small   => "300x300",
       :banner => "728x190#"
     }
   }
   
  has_attached_file :banner, attachment_options
   
  def to_s
    name
  end 
  
end
