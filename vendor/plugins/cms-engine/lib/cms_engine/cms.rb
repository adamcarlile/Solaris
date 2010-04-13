module CmsEngine

  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../..'))

  class << self
    def override_page_type(name, package = nil)
      package ||= name
      require_dependency File.join(CmsEngine::ROOT, "app/page_types/#{package}/#{name}")
    end
  end
  
  class Base

    cattr_accessor :page_type_classes

    class << self
      
      def init
        logger.info '='*100
        logger.info 'Initializing CMS Engine'
        
        page_type_classes = []
        load_page_types
        add_view_paths
        make_app_files_reload_in_development
        logger.info '='*100
      end

      def page_type_paths
        [File.join(RAILS_ROOT,'app/page_types'), File.join(CmsEngine::ROOT,'app/page_types')]
      end

      # Page types in engine are loaded first so that if a copy exists in app/page_types it can override the existing class
      def load_page_types
        logger.info ' - Loading page types'
        # Add all the load paths before loading the ruby files in case one page type needs to refer to another
        page_type_paths.each do |path|
          add_load_paths_for_page_types_in_dir(path)
        end
        # Then load up the ruby files, they woudl auto load but we need to know which page type classes get defined
        page_type_paths.each do |path|
          load_page_type_classes_in_dir(path)
        end
        self.page_type_classes = Page.send(:subclasses)
        logger.info "Loaded the following page type classes: #{self.page_type_classes.map(&:to_s).join(', ')}"
      end

      # View paths are added in the opposite order to page type loading so that views in app/page_types take priority
      def add_view_paths
        page_type_paths.each do |path|
          ActionController::Base.append_view_path path
        end
      end

      def add_load_paths_for_page_types_in_dir(dir_path)
        logger.info " - Looking for page types in #{dir_path}"
        Dir["#{dir_path}/*"].each do |path|
          logger.info "    adding page type #{path.split('/').last}"
          ActiveSupport::Dependencies.load_paths << path
        end
      end

      def load_page_type_classes_in_dir(dir_path)
        Dir["#{dir_path}/*"].each do |path|
          logger.info "    load page type files in #{path.split('/').last}"
          Dir["#{path}/*.rb"].each do |file_path|
            logger.info " -     loading #{file_path}"
            require_dependency file_path
          end
        end
      end

      def make_app_files_reload_in_development
        %w(controllers helpers).each do |folder_name|
          path = File.join(CmsEngine::ROOT,'app',folder_name)
          ActiveSupport::Dependencies.load_once_paths.delete(path)
        end
      end

      def logger
        RAILS_DEFAULT_LOGGER
      end
      
    end  

  end
end
