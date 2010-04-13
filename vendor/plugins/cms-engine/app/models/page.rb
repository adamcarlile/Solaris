class Page < ActiveRecord::Base
  include NamedScopeHelpers

  is_userstamped
  is_publishable  
  is_versioned :versioned_columns => %w(publish_from publish_to title meta_title meta_description meta_keywords nav_title url intro body tag_list) do
    has_many :attachments, :class_name => "::PageVersionAttachment", :foreign_key => 'page_version_id', :dependent => :delete_all
  end
  acts_as_taggable
  acts_as_commentable

  named_scope :top_level, :conditions => {:ancestry => nil}
  named_scope :published_top_level, :conditions => "#{CmsEngine::Acts::Publishable::PUBLISHED_CONDITIONS} AND ancestry IS NULL"
  named_scope :with_type, lambda { |q| { :conditions => {'type' => q.to_s.camelize} } }
#  named_scope_with_exact_match :with_parent, :parent_id
  named_scope :limit, lambda {|n| {:limit => n} }
  named_scope :in_date_range, lambda{|range| { :conditions => ["DATE(created_at) BETWEEN ? AND ?", range.begin.to_date, range.end.to_date] } }
  
  has_many :attachments, :class_name => "::Attachment", :dependent => :delete_all

  %w(image file_upload).each do |t|
    define_method(t.pluralize) do
      attachments.of_type(t.camelize).map(&:attachable).compact
    end
  end

  def image
    attachments.of_type('Image').find(:first)
  end

  def after_version_created
    if versions.count > 1 and published?
      fire_event_with_history_logging(:draft, current_user)
    end
  end
  
  def create_version?
    super or (!new_record? and attachments_changed?)
  end
  
  def attachments_changed?
    return true if attachments.any?(&:marked_for_destruction?)
    return false if attachments == Page.find(id).attachments
    return true if attachments.length != latest_version.attachments.length
    attachments.each_with_index do |a, i|
      return true unless a.same_as?(latest_version.attachments[i])
    end
    false
  end

  def save_collection_association(reflection)
    unless reflection.name == :attachments
      super
    end
  end
  
  def destroy_attachment(attachment)
    attachments.select{|a| a.id = attachment.id}.each &:mark_for_destruction
    save
  end

  # extend to also copy attachments
  def copy_attributes(from_object, to_object)
    unless new_record?
      # If copying to a new version, check if attachments have been modified in this page
      # if so, copy to the new version, otherwise give new version same attachments as previous version
      if attachments_changed? or to_object.is_a?(Page)
        copy_attachments(from_object, to_object)
      elsif from_object.is_a?(Page) && latest_version
        # new version gets same attachments as latest version
        copy_attachments(latest_version, to_object)
      end
    end
    super
  end
  
  # Copy attachments between a page and version (when creating new version), 
  # from a version to another version (when creating a new version and attachments are unchanged)
  # or from a version to a page (when publishing a version)
  def copy_attachments(from_object, to_object)
    # clear existing attachments 
    to_object.attachments.each {|a| a.destroy(true)}
    # and reload the association
    to_object.attachments(true)
    # copy the attachments over
    from_object.attachments.reject{|a| a.marked_for_destruction?}.each do |a|
      attachment = to_object.attachments.build(:attachable => a.attachable, :position => a.position, :container => a.container)
      attachment.save if to_object.is_a?(Page)
    end
  end
  
  # If a version is being previewed, get the attachment from the version instead
  alias_method :original_attachments, :attachments
  def attachments(*args)
    viewing_version ? viewing_version.attachments(*args) :  original_attachments(*args)
  end
  
  def build_attachments_from_version(version_in_question)
    attachments.each &:mark_for_destruction
    version_in_question.attachments.each do |a|
      attachment = attachments.build(:attachable => a.attachable, :position => a.position, :container => a.container)
    end
  end
  
  def versioned?
    true
  end

  def attachments_attributes=(attachment_attributes)
    raise 'Invalid attachment attributes' unless attachment_attributes.is_a?(Array)

    attachment_attributes.each do |attributes_for_attachment|
      mark_for_destroy = attributes_for_attachment.delete(:_delete)

      # If attachments have been added and latest versio published, the page record
      # will already have saved attachment records when this method is called
      # only build an attachment if an existing one can't be found with matching attachable
      if attachment = attachments.detect{|a| a.attachable_type == attributes_for_attachment[:attachable_type] && a.attachable_id.to_s == attributes_for_attachment[:attachable_id].to_s }
        attachment.attributes = attributes_for_attachment
      else
        attachment = attachments.build(attributes_for_attachment)
      end

      if mark_for_destroy
        attachment.mark_for_destruction
      end
    end
  end

  def clear_changes
    @new_tag_list = nil
    super
  end
  
  
  validates_presence_of :title
  validates_presence_of :publish_from

  acts_as_tree
  default_scope :order => 'position'
  before_validation_on_create :set_default_publish_from
  before_save :set_slug, :set_paths
  after_save :set_child_paths
  after_save :cache_top_level_page_id
  before_create :add_to_bottom_of_list

  attr_accessor :type_name
  
  def set_default_publish_from
    self.publish_from ||= Date.today.to_time
  end
  

  #
  # Set up class methods for each of the following page options allowing them to be set
  # with a macro that'll create the class method accessor
  # Page subclasses can either define a class method to override these or use the setter method
  #
  # can_have_children = true
  #
  # def self.can_have_children
  #   true
  # end
  #
  %w(can_have_children can_have_comments visitable allowed_child_types archive show_in_nav page_type_package admin_template public_template extra_path_params).each do |method_name|
      Page.class_eval <<-EOS
        def self.#{method_name}=(value)
          meta_def :#{method_name} do
            value
          end
          meta_def :#{method_name}? do
            value
          end
        end
        def #{method_name}
          self.class.#{method_name}
        end
        def #{method_name}?
          self.class.#{method_name}
        end
     EOS
  end
  
  # Defaults for page type properties
  self.can_have_children   = true
  self.visitable           = true
  self.can_have_comments   = false
  self.allowed_child_types = [:basic_page,:folder,:news_index,:hyperlink,:redirect, :faq_index]
  self.archive             = false
  self.show_in_nav         = true
  self.extra_path_params   = []
  
  def self.admin_template
    "#{page_type_package}/views/admin/#{page_type_name}"
  end
  
  def self.public_template
    "#{page_type_package}/views/public/#{page_type_name}"
  end

  def self.type_classes
    raise 'not implemented, type_classes'
    subclasses
  end
  def self.type_names
    raise 'not implemented, type_names'
  end



  def self.page_type_name
    self.to_s.underscore
  end
  
  def self.page_type_package
    page_type_name
  end




  def deleteable?
    !locked?
  end
  
  
  def self.find_by_slug_path_with_extra_path_params(slug_path, show_unpublished = false)
    scope = show_unpublished ? Page : Page.published

    path_segments = slug_path.split('/')
    spare_segments = []
    page = nil

    until path_segments.empty? or page
      unless page = scope.find_by_slug_path(path_segments.join('/'))
        spare_segments.unshift(path_segments.pop)
      end
    end
    
    begin
      extra_params = page ? page.map_extra_path_params(spare_segments) : {}
    rescue
      return [nil, {}]
    end

    [page, extra_params]
  end
  
  def map_extra_path_params(path_segments)
    return {} if path_segments.empty?
    raise 'path segments didnt match extra_path_params' unless extra_path_params.length == path_segments.length
    extra_path_params.inject({}){|params, key| params.merge(key => path_segments.shift) }
  end

  def published_children_count
    children.published.count
  end

  def published_children_for_nav
    @published_children_for_nav ||= children.published.find(:all, :order => 'position').select{|c| c.show_in_nav?}
  end

  def root_ancestor
    return nil unless parent
    ancestor = self
    while ancestor.parent.parent
      ancestor = ancestor.parent
    end
    ancestor
  end

  # Is this page a top level item in the site structure, not necessarily in the 
  # whole content tree where it may be a child of 'Global Nav' etc.
  def top_level?
    slug == slug_path
  end

  def can_have_user_permissions?
    top_level?
  end

  def children_count
    children.count
  end

  def render(params)
    {}
  end

  def to_s
    title
  end
  
  def nav_title
    if attributes['nav_title'].blank?
      title
    else
      attributes['nav_title']
    end
  end

  def set_slug
    return unless title_changed? || nav_title_changed?
    self.slug = if parent.nil?
      nil
    else
      nav_title.url_friendly
    end
  end
  
  def set_paths
    return unless title_changed? || nav_title_changed?
    if parent.nil?
      self.slug_path = nil
    else
      self.slug_path = (ancestors.map(&:slug).reject{|a|a.blank?}.reverse << slug).join('/')
    end
    #self.title_path = (ancestors.map(&:title).reject{|a|a.blank?}.reverse << title).join(' &gt; ')
  end
  
  def set_child_paths
    children.each do |child|
      child.set_paths
      child.save
      unless child.children.count == 0
        child.set_child_paths
      end
    end
  end
  
  def cache_top_level_page_id
    if top_level_page = root_ancestor
      self.top_level_page_id = top_level_page.id
      connection.execute(self.class.send(:sanitize_sql,["UPDATE pages SET top_level_page_id = ? WHERE pages.id = ?", top_level_page.id, id]))
    end
  end
  
  
  def add_to_bottom_of_list
    if parent
      highest_sibling_position = parent.children.map{|p| p.position.to_i }.max.to_i
      self.position = highest_sibling_position + 1
    else
      self.position = 1
    end
  end
  
  def self.published_with_tags(tags, find_options = {})
    tagged_with_scope(tags, {}) do
      published.find(:all, find_options.merge(:select =>  "DISTINCT #{table_name}.*"))
    end
  end
  

  #
  # Search index
  #
  
  acts_as_xapian :texts => [:search_text], :if => :indexable?
  
  def indexable?
    visible_on_site?
  end
  
  def search_text
    [title, intro, body, meta_description, meta_keywords, meta_title].join(' ')
  end

  #
  # User permissions
  #
  has_many :user_page_permissions
  has_many :users_with_permissions, :through => :user_page_permissions, :source => :user, :class_name => 'User'
  
  def editable_by?(user)
    user.has_role?(:writer) or has_permission_for_user?(:edit, user)
  end

  def publishable_by?(user)
    user.has_role?(:editor) or has_permission_for_user?(:publish, user)
  end
  
  def has_permission_for_user?(permission_name, user)
    return false unless root_ancestor
    !! root_ancestor.user_page_permissions.find(:first, :conditions => {:user_id => user.id, permission_name => 1})
  end
  
  def users_who_can_publish
    user_list = Role.editor.users
    if root_ancestor
      user_list += root_ancestor.user_page_permissions.with_publish_permission.map(&:user)
    end
    user_list.uniq
  end

  named_scope :editable_by, lambda { |user|  
    page_ids = user.user_page_permissions.all(:conditions => {:publish => true}).map(&:page_id)
    { :conditions => {:top_level_page_id => page_ids}  }       
  }
  
  
  #
  # Restricted to logged in users
  #
  def restricted?
    ancestors.any?{|p| p.children_restricted?}
  end
  
end
