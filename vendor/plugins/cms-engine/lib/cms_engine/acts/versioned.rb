# Act for any models that require version control
# Overrides save behaviour to create a new version isntead of updating the original record
module CmsEngine
  module Acts
    module Versioned   

      # Columns that are not considered versionable if is_versioned doesn't specify columns
      RESERVED_COLUMNS = %w(version created_at created_by_id updated_at updated_by_id user_id)

      def self.included(base)
        base.extend(MacroMethods)
      end

      module MacroMethods
        def versioned?
          !!@is_versioned
        end

        def is_versioned(options = {}, &blk)
          @is_versioned = true

          define_callbacks :after_version_created

          cattr_accessor :version_foreign_key, :version_table_name, :versioned_columns
          self.version_foreign_key = (options[:version_foreign_key] || "#{name.underscore}_id").to_s
          self.version_table_name = (options[:version_table_name] || "#{table_name.singularize}_versions").to_s
          self.versioned_columns = options[:versioned_columns] || (Page.content_columns.map(&:name) - CmsEngine::Acts::Versioned::RESERVED_COLUMNS)

          alias_method :save_without_versioning, :save            

          extend ClassMethods
          include InstanceMethods

          has_many :versions, :class_name  => version_class_name, :foreign_key => version_foreign_key, :dependent => :delete_all, :order => 'id'
          has_many :version_users, :through => :versions, :class_name => 'User', :source => :user
          
          attr_accessor :version_comment
          attr_accessor :viewing_version
          attr_accessor :revert_error

          const_set("Version", Class.new(ActiveRecord::Base)).class_eval do 
            class << self
              attr_accessor :versioned_class
            end
            belongs_to :user

            def latest?
              newer_versions.empty?
            end
            def revertable?
              !latest? && (version != versioned_object.version)
            end
            def newer_versions
              versioned_object.versions.all(:conditions => ['version > ?', version])
            end
            def versioned_class
              self.class.versioned_class
            end
            def versioned_object_id
              send("#{versioned_class.name.underscore}_id")
            end
            def versioned_object
              send(versioned_class.name.underscore.to_sym)
            end                 
          end
          version_class.versioned_class = self
          version_class.belongs_to(name.underscore.to_sym, :foreign_key => version_foreign_key)
          if block_given?
            version_class.class_eval(&blk)
          end
        end

      end


      module ClassMethods
        def version_class
          const_get "Version"
        end

        def version_class_name
          "#{name}::Version"
        end        
      end


      module InstanceMethods       

        def create_version?
          new_record? or has_changes_to_versioned_columns?
        end

        # Check if versioned attributes are different to those in latest version
        # body only check those that have actually been changed as only changed
        # attributes will be versioned
        def has_changes_to_versioned_columns?
          !! changed_versioned_columns.detect do |key|
            send(key).is_a?(Paperclip::Attachment) ? 
            send(key).is_a?(Paperclip::Attachment) && send(key).dirty? :
            send(key) != latest_version.send(key)
          end
        end

        def changed_versioned_columns
          versioned_columns & changed
        end

        def save(perform_validations = true)
          create_version? ? save_with_versioning(perform_validations) : save_without_versioning(perform_validations)
        end        

        def save!(perform_validations=true)
          save || raise(ActiveRecord::RecordNotSaved.new(errors.full_messages))
        end

        def save_with_versioning(perform_validations = true)
          return false if perform_validations and !valid?

          transaction do
            new_version = build_new_version
            if new_record?

              self.version = 1
              callback(:before_save)
              callback(:before_create)
              if create_without_callbacks
                if callback(:after_create) != false
                  callback(:after_save)
                end
                clear_changes
              end

            elsif new_version

              clear_changes
              if new_version.save
                # Perform a regular save of the original record to update timestamps and perform callbacks
                # Because changes have been cleared to prevent content changes been written to the original record,
                # an update query wouldn't happen so manually set updated_at
                self.updated_at = Time.now
                save_without_versioning
              end

            end
          end
          callback(:after_version_created)
          true
        end

        # Clear any changes to original record preventing changes being commited that should only be saved to a version
        # Only clear changes to versioned columns allowing non-versioned columns to be saved normally
        def clear_changes
          versioned_columns.each do |key|
            changed_attributes.delete(key)
          end
        end

        def build_new_version
          # build a new version if this will be the first
          # otherwise clone the previous version so its attributes are the starting point
          # to be overwritten by modified attributes on the record itself
          new_version = latest_version ? latest_version.clone : versions.build

          copy_attributes(self, new_version)
          new_version.version_comment = version_comment
          new_version.version = (new_record? || latest_version.nil?) ? 1 : (latest_version.version + 1)
          new_version.user = current_user
          after_build_new_version(new_version) if respond_to?(:after_build_new_version)
          new_version
        end

        # A hash of attributes from the versioned object to be set on a new version                
        def attributes_for_version
          versioned_attributes_from_object(self)
        end 

        def attributes_from_version(version_in_question)
          versioned_attributes_from_object(version_in_question)
        end

        # Get Hash of attributes that are versioned from either the original object or one of its versions
        def versioned_attributes_from_object(object)
          self.class.versioned_columns.inject({}){|attrs, col| attrs[col] = object.send(col); attrs }
        end

        # Copy versioned attributes from an object to a version or vice-versa
        # Enable Paperclip compatability by writing the original file name
        def copy_attributes(from_object, to_object)
          from_object_attributes = versioned_attributes_from_object(from_object)

          # Just setting a Paperclip attachment as an attribute won't work, original file name is lost
          from_object_attributes.each do |k,v|  
            if v.is_a?(Paperclip::Attachment)
              # Handle a paperclip attachment
              # If an attribute value is a Paperclip attachment, set the original file name so 
              # the correct file name is maintained when copying between object and version or vice-versa
              # When copying between object and version, only write the file name is there is an attachment queued for write
              # It won't be queued for write when publishing back from version to object
              to_object.send("#{k}=", v)
              to_object.send(k).instance_write(:file_name, v.instance_read(:file_name))
            else
              # Handle a regular attribute
              # When copying from a version to a record (publishing a version), all attributes can be copied over
              # When copying to a version, only copy over changed attributes
              if to_object.is_a?(self.class) || changed.include?(k)
                to_object.send("#{k}=", v)
              end
            end
          end

        end

        def latest_version
          versions.first(:order => 'version DESC')
        end

        def published_version
          versions.find_by_version(version)
        end

        def has_unpublished_changes?
          version < latest_version.version
        end

        # When editing a page, we want to see the latest version's content, not the published content
        def preview_latest_version
          load_attributes_from_version(latest_version)
        end
        def load_attributes_from_version(version_in_question)
          self.viewing_version = version_number_to_version(version_in_question)
          version_in_question = version_number_to_version(version_in_question)
          version_attributes = attributes_from_version(version_in_question)
          # only copy regular attributes, copying attachment is costly and unecessary
          version_attributes.delete_if{|k,v| v.is_a?(Paperclip::Attachment)}
          send(:attributes=, version_attributes, false)
        end

        # Update the original record with the content from the latest version
        def publish_latest_version    
          publish_version(latest_version)
        end

        # Get a version record for supplied version number, or if supplied a version record just return it
        def version_number_to_version(version_or_version_number)
          unless version_or_version_number.is_a?(self.class.version_class)
            version_or_version_number = versions.find_by_version(version_or_version_number.to_i)
          end
          version_or_version_number
        end

        # Update the original record with the content from a specifiec version or version number
        def publish_version(version_in_question)
          version_in_question = version_number_to_version(version_in_question)
          raise "Invalid version" if version_in_question.nil?
          transaction do
            copy_attributes(version_in_question, self)
            self.version = version_in_question.version
            callback(:before_save)
            update_without_dirty # because changed_attributes is cleared after new version is created, regular update might skip versioned columns
            callback(:after_save)
          end            
        end

        def revert_to_version(version_in_question)
          version_in_question = version_number_to_version(version_in_question)
          if version_in_question.revertable?
            load_attributes_from_version(version_in_question)
            if create_version?
              save
              true
            else
              self.revert_error = 'Chosen version is identical to latest version'
              false
            end
          else
            self.revert_error = 'Chosen version is not revertable'
            false
          end
        end

        def contributors
          users_from_versions = version_users.find(:all, :select => "distinct users.*")
          (users_from_versions + [created_by]).compact.uniq
        end

      end

    end
  end
end
