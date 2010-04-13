class Tagging < ActiveRecord::Base
  belongs_to :tag, :counter_cache => true
  belongs_to :taggable, :polymorphic => true
  belongs_to :user
  
  named_scope :with_type_scope, lambda {|types| {:conditions => {:taggable_type => types.to_a}} }
end