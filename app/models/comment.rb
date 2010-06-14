require File.join('vendor/plugins/cms-engine/app/models/comment')
class Comment < ActiveRecord::Base
  is_gravtastic! :email, :filetype => :gif, :size => 55
end