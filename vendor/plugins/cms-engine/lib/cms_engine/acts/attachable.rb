# Act for any models that can be attached to a page
module CmsEngine
  module Acts
    module Attachable
      
      def self.included(base)
        base.extend(MacroMethods)
      end
      
      module MacroMethods
        def is_attachable(options = {})

          has_many :attachments, :class_name => "::Attachment", :as => :attachable, :dependent => :delete_all
          has_many :page_version_attachments, :class_name => "::PageVersionAttachment", :as => :attachable, :dependent => :delete_all

          named_scope :with_keyword, lambda {|q| {:conditions => ["title LIKE ?", "%#{q}%"]} }
          named_scope :excluding_ids, lambda {|ids| {:conditions => ["id NOT IN (?)", ids]} }

          include InstanceMethods
        end
      end

      module InstanceMethods
      end
            
    end
  end
end