namespace :plugin do
  namespace :banners do
    namespace :db do
      task :migrate => :environment do
        ActiveRecord::Migrator.migrate(File.expand_path(File.dirname(__FILE__) + "/../db/migrate"))
        Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
      end
    end
  end
end