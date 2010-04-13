namespace :cms do
  
  namespace :db do

    task :bootstrap => :environment do |task_args|

      puts '-'*100
      puts 'Loading schema'

      Rake::Task["db:schema:load"].execute

      puts '-'*100
      puts 'Loading initial data'
      require "#{RAILS_ROOT}/db/seed.rb"

      puts '-'*100
      puts 'Done'
      puts '-'*100

    end

    task :migrate => :environment do
      ActiveRecord::Migrator.migrate(File.expand_path(File.dirname(__FILE__) + "/../db/migrate"))
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end

  end

  namespace :versioning do
    task :migrate_versioned_models => :environment do
      [Page,Image,FileUpload].each do |klass|
        klass.all.each do |page|
          page.create_missing_version_1
        end
      end
    end
  end
    
  namespace :search_index do
    task :rebuild => :environment do 
      models = SearchIndex.indexed_classes - CmsEngine::Base.page_type_classes + [Page]
      puts "rebuilding index for the following models: #{models.map(&:to_s).join(', ')}"
      ActsAsXapian.rebuild_index(models, ENV['verbose'] ? true : false)
    end
    task :update => :environment do 
      ActsAsXapian.update_index(ENV['flush'] ? true : false, ENV['verbose'] ? true : false)
    end
  end

end
