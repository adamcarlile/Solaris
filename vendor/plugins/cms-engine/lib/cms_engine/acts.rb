module CmsEngine::Acts; end

Dir["#{File.dirname(__FILE__)}/acts/*.rb"].each do |b| 
  require_dependency File.join("cms_engine", "acts", File.basename(b, ".rb"))
  ActiveRecord::Base.send(:include, "CmsEngine::Acts::#{File.basename(b, ".rb").camelize}".constantize)
end
