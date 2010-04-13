require CmsEngine::ROOT + '/vendor/plugins/acts_as_taggable_redux/lib/tag.rb'
class Tag < ActiveRecord::Base

  make_permalink
  
  def to_param
    name.parameterize.to_s
  end

end