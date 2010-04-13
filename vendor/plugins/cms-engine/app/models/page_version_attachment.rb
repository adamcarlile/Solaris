class PageVersionAttachment < ActiveRecord::Base  

  belongs_to :page_version, :class_name => 'Page::Version', :foreign_key => 'page_version_id'
  belongs_to :attachable, :polymorphic => true

  default_scope :order => 'position'
  named_scope :of_type, lambda {|t| {:conditions => {:attachable_type => t}} }

  def save_belongs_to_association(reflection)
  end


  # To deterime if a @page's attachments have changed, they're compared against those in the 
  # latest version. This is used to make the comparison between each item
  def same_as?(other)
    position == other.position &&
    attachable_id == other.attachable_id &&
    attachable_type == other.attachable_type
  end

end