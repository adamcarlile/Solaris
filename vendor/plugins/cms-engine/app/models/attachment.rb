class Attachment < ActiveRecord::Base
  belongs_to :page
  belongs_to :attachable, :polymorphic => true
  
  validates_presence_of :page, :attachable
  validates_associated :attachable
  
  default_scope :order => 'position'
  named_scope :of_type, lambda {|t| {:conditions => {:attachable_type => t}} }

  acts_as_list :scope => :page
  
  
  # Override so when user tries to destroy a page's attachment a new version of the page is created instead
  def destroy(force = false)
    super() and return if force
    page.destroy_attachment(self)
  end
  
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
