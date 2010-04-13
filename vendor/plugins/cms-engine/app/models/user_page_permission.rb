class UserPagePermission < ActiveRecord::Base
  
  belongs_to :page
  belongs_to :user

  validates_presence_of :page, :user
  validates_uniqueness_of :user_id, :scope => 'page_id', :message => "User permission already added for this user"
  
  validate :must_have_one_permission_enabled
  validate :page_must_be_allowed_to_have_permissions_assigned

  named_scope :with_edit_permission, :conditions => {:edit => true}
  named_scope :with_publish_permission, :conditions => {:publish => true}

  include CmsEngine::UserAssignmentByIdentifier
  
  def must_have_one_permission_enabled
    unless edit? or publish?
      errors.add(:edit, "At least one permission must be selected")
    end
  end
  
  def page_must_be_allowed_to_have_permissions_assigned
    if page and !page.can_have_user_permissions?
      errors.add(:page, "can't have user permissions assigned")
    end
  end
  
  
end