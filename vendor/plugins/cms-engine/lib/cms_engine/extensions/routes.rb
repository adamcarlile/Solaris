if defined?(ActionController::Routing::RouteSet)
  class ActionController::Routing::RouteSet
    def load_routes_with_engine!
      lib_path = File.dirname(__FILE__)
      engine_routes = File.join(lib_path, *%w[.. .. .. config engine_routes.rb])
      unless configuration_files.include?(engine_routes)
        add_configuration_file(engine_routes)
      end
      load_routes_without_engine!
    end

    alias_method_chain :load_routes!, :engine
  end
end
