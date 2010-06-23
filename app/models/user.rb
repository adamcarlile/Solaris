require File.join('vendor/plugins/cms-engine/app/models/user')
class User < ActiveRecord::Base

  has_many :events

end