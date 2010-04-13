# Records which user create and last updated
module CmsEngine
  module Acts
    module Userstamped
      
      def self.included(base)
        base.extend(MacroMethods)
      end
      
      module MacroMethods

        def userstamped?
          !!@is_userstamped
        end

        def is_userstamped(options = {})
          @is_userstamped = true

          attr_accessor :current_user

          include InstanceMethods

          belongs_to :created_by, :class_name => "User"
          belongs_to :updated_by, :class_name => "User"

          before_save :set_userstamps
          
          named_scope :created_by, lambda{|user| {:conditions => {:created_by => user}}}        
          named_scope :updated_by, lambda{|user| {:conditions => {:updated_by => user}}}        

        end
      end

      module InstanceMethods
        def set_userstamps
          if new_record?
            self.created_by = current_user
          end
          self.updated_by = current_user
        end
      end
            
    end
  end
end