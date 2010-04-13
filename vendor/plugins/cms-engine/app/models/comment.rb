class Comment < ActiveRecord::Base

  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true

  default_scope :order => 'created_at ASC'
  named_scope :approved, :conditions => 'approved = 1'
  named_scope :pending_approval, :conditions => 'approved = 0'

  belongs_to :user

  attr_accessible :name, :comment, :email, :commentable_id, :commentable_type
  
  validates_presence_of :name, :comment

  def validate_on_create
    if commentable && 
      ( commentable.respond_to?(:can_have_comments?) and !commentable.can_have_comments? ) || !commentable.respond_to?(:comments)
      errors.add_to_base('Comment not allowed on this item')
    end
    #if commentable && commentable.respond_to?(:allow_new_comments?) && 
    #if !commentable.allow_new_comments?
    #  errors.add_to_base('Comment are disabled for this item')
    #end
    if ip && !ip_can_comment?
      errors.add_to_base('Sorry, only one comment allowed per hour')
    end
  end

  def approve!
    update_attribute(:approved, true)
  end
  
  def ip_can_comment?
    ! self.class.find(:first, :conditions => ['ip = ? AND created_at > ?', ip, 1.hour.ago])
  end
  
end
