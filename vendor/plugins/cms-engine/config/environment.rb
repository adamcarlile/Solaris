config.plugin_paths += %W( #{RAILS_ROOT}/vendor/plugins/cms-engine/vendor/plugins )
config.plugins = [ :find_by_param, :all ]

config.load_paths += %W( #{RAILS_ROOT}/vendor/plugins/cms-engine/app/models/page_types )

config.gem "mislav-will_paginate", :version => ">= 2.3.0", :lib => "will_paginate", :source => "http://gems.github.com"
config.gem "authlogic", :version => ">= 2.0.9"
config.gem "giraffesoft-resource_controller", :lib => "resource_controller",  :version => ">= 0.6.1", :source => "git://github.com/giraffesoft/resource_controller.git"
config.gem 'RedCloth', :lib => 'redcloth'
config.gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"
config.gem 'faker'
config.gem 'cucumber'
config.gem 'ancestry'
