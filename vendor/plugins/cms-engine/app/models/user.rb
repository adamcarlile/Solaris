require 'digest/sha1'

class User < ActiveRecord::Base

  acts_as_authentic

  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    UserMailer.deliver_password_reset_instructions(self)  
  end

  attr_protected :role, :role_id, :role_ids, :state
  

	def to_s
		name
	end

  def name
    "#{firstname} #{lastname}"
  end
  
  
  # Roles
  has_and_belongs_to_many :roles
  
  def has_role?(role_in_question)
    role_names.include?(role_in_question.to_s)
  end
  
  def role_names
    @role_names ||= roles.map(&:name)
  end
  
  %w(can_manage_users? can_manage_images? can_manage_files? can_manage_comments?).each do |name|
    define_method(name) do
      roles.any? {|r| r.send(name)}
    end
  end
  
  # Page specific permissions
  has_many :user_page_permissions

  named_scope :with_name_like, lambda {|q| {:conditions => ["CONCAT(firstname,' ',lastname) LIKE ?", "%#{q}%"]} }
  named_scope :limit, lambda {|n| {:limit => n} }
  named_scope :with_roles, lambda {|role_ids| {:include => :roles, :conditions => ["roles.id in (?)", role_ids]} }

  has_many :publishable_events, :dependent => :destroy
  has_many :assigned_publishable_events, :class_name => 'PublishableEvent', :order => 'created_at DESC', :foreign_key => 'assigned_user_id', :dependent => :destroy
  
  def admin?
    has_role?(:admin)
  end
  
  def member?
    roles.empty?
  end
  
  # State
  state_machine :state, :initial => :pending do
    event :activate do
      transition :pending => :active
    end
    event :reject do
      transition :pending => :rejected
    end
    event :suspend do
      transition :active => :suspended
    end
    event :un_suspend do
      transition :suspended => :active
    end
    after_transition :on => :activate do |object, transition|
      UserMailer.deliver_account_activated(object)
    end
  end
  after_create :deliver_account_created_notification
  
  def deliver_account_created_notification
    if pending?
      UserMailer.deliver_account_created(self)
    end
  end
  

  

end