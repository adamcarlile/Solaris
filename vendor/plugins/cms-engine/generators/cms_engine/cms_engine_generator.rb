class CmsEngineGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file 'site_settings.rb', 'config/initializers/site_settings.rb'
      m.file 'cms_engine.rb', 'config/initializers/cms_engine.rb'
      m.file 'db/seed.rb', 'db/seed.rb'
      m.file 'db/schema.rb', 'db/schema.rb'
      m.file 'config/environments/cucumber.rb', 'config/environments/cucumber.rb'

      m.directory File.join("features", "step_definitions")
      m.directory File.join("features", "support")

      ["features/step_definitions/record_steps.rb",
        "features/step_definitions/shared_steps.rb",
        "features/step_definitions/table_steps.rb",
        "features/step_definitions/webrat_steps.rb",
        "features/step_definitions/comment_steps.rb",
        "features/support/paths.rb",
        "features/support/env.rb",
        "features/support/resource_helpers.rb",
        "features/support/custom_html_formatter.rb",
        "features/basic_pages.feature",
        "features/cms_login.feature",
        "features/creating_pages.feature",
        "features/commenting.feature"
       ].each do |file|
        m.file file, file
       end

      unless File.exists?(File.join(RAILS_ROOT,'public/cms'))
        FileUtils.ln_s(File.join(CmsEngine::ROOT,'public'), File.join(RAILS_ROOT,'public/cms'))
      end
      
    end
  end
end
