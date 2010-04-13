# The most basic type of workflow.
# Items start off as draft and can be published. 
# After publishing, they can be unpublished, returning them to draft"
module CmsEngine
  module Workflow
    module DraftPublishedWorkflow
      
      class << self
        def included(base)
          base.state_machine :state, :initial => :draft do
            state :draft
            state :published
            event :publish do
              transition [:draft] => :published
            end
            event :unpublish do
              transition :published => :draft
            end
          end
        end

      end
    end
  end
end