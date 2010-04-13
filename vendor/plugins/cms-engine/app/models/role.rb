class Role < ActiveRecord::Base
  
  has_and_belongs_to_many :users
  
  NAMES = %w(cms_user writer editor admin)
  
  class << self
    NAMES.each do |name|
      define_method(name) do
        find_by_name(name)
      end
    end
  end  
  
  
  
  # Simple permissing checking methods
  
  def can_manage_users?
    name == 'admin'
  end
  def can_manage_images?
    name == 'writer'
  end
  def can_manage_files?
    name == 'writer'
  end
  def can_manage_comments?
    name == 'editor'
  end

end