# Simple workflow for use with version control
# Allows content to be reviewed by an editor before publishing
module CmsEngine
  module Workflow
    module BasicPublishingWorkflow

      def self.included(base)
        
        base.send(:include, InstanceMethods)
        
        base.state_machine :state, :initial => :draft, :action => :save_without_versioning do

          #
          # Posible states
          #

          # Item has unpublished changes or is invisible
          state :draft
          # Item has unpublished changes that are pending review by an editor
          state :pending_review
          # Item is visible and all changes are published
          state :published

          #
          # Events
          #

          event :draft do
            transition any - :draft => :draft
          end
          
          # A writer has completed their changes and wants an editor to review before publishing
          event :submit_for_review do
            transition :draft => :pending_review
          end
          
          # A writer changes their mind after submitting for review, returning the page to draft status
          event :retract do
            transition [:pending_review] => :draft
          end
          
          # An editor wants the writer to make further changes to an item before it can be published
          event :send_back do
            transition [:pending_review] => :draft
          end

          # An editor is happy with changes and makes the item live
          event :publish do
            transition [:draft, :pending_review] => :published
          end

          # An editor can hide a page from the site
          event :unpublish do
            transition [:published] => :draft
          end


          after_transition :on => :publish do |object, transition|
            object.update_attribute(:visible, true) unless object.visible?
            object.publish_latest_version
          end

          after_transition :on => :unpublish do |object, transition|
            object.update_attribute(:visible, false) if object.visible?
          end

        end
      end

      module InstanceMethods
        
        def state_events_for_user(user)
          state_events.select{|e| user_can_fire_event?(user, e)}
        end
        
        def user_can_fire_event?(user, event_name)
          case event_name
            when *[:submit_for_review, :retract]
              editable_by?(user)
            when *[:draft, :send_back, :publish, :unpublish]
              publishable_by?(user)
            else
              false
          end
        end
   
        def make_draft
          puts 'Make draft!'
        end
        
      end

    end
  end
end