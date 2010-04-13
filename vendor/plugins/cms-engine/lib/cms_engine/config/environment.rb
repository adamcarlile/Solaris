Rails::Initializer.run do |config|
  config.plugin_paths += %W( #{RAILS_ROOT}/vendor/plugins/cms-engine/vendor/plugins )

  config.gem "authlogic", :version => ">= 2.0.9"
  config.gem "giraffesoft-resource_controller", :lib => "resource_controller",  :version => ">= 0.6.1", :source => "git://github.com/giraffesoft/resource_controller.git"
  config.gem 'RedCloth', :lib => 'redcloth'
  config.gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"
  config.gem 'faker'
  config.gem 'cucumber'
  
  config.load_paths += %W( #{RAILS_ROOT}/vendor/plugins/cms-engine/app/models/page_types )

end
