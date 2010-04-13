# Act for any models that have publishing workflow
module CmsEngine
  module Acts
    module Publishable
      
      PUBLISHED_DATE_CONDITIONS = '(publish_from IS NULL OR publish_from <= CURDATE()) AND (publish_to IS NULL OR publish_to >= CURDATE())'
      PUBLISHED_STATE_CONDITIONS = "visible = 1"
      PUBLISHED_CONDITIONS = "(#{PUBLISHED_DATE_CONDITIONS}) AND (#{PUBLISHED_STATE_CONDITIONS})"

      def self.included(base)
        base.extend(MacroMethods)
      end

      module MacroMethods
        def is_publishable(options = {})

          named_scope :published, :conditions => CmsEngine::Acts::Publishable::PUBLISHED_CONDITIONS
          named_scope :most_recent_first, :order => 'publish_from DESC'
          
          has_many :publishable_events, :as => :publishable, :order => 'publishable_events.created_at', :dependent => :destroy
          
          attr_accessor :workflow_comment
          
          options[:workflow] ||= CmsEngine::Workflow::BasicPublishingWorkflow
          include options[:workflow]

          include InstanceMethods
        end
      end

      module InstanceMethods

        # Visible on site, i.e. meets the same criteria as PUBLISHED_CONDITIONS
        def visible_on_site?
          visible? && 
          (publish_to.nil? || publish_to.to_date >= Date.today) &&
          (publish_from.nil? || publish_from.to_date <= Date.today)
        end

        # publish_from is most appropriate date for display in pages like news but its optional so display created_at if its not set
        def publish_date
          publish_from || created_at
        end

        def fire_event_with_history_logging(event_name, user, assigned_user = nil)
          state_event = self.class.state_machines[:state].event(event_name)
          transition = state_event.transition_for(self)
          if transition and (user.nil? || user_can_fire_event?(user, event_name))
            transaction do
              send("#{event_name}!")
              publishable_events.create(:user => user, :assigned_user => assigned_user, :event_name => state_event.name.to_s, :from_state => transition.from, :to_state => transition.to, :comment => workflow_comment)
            end
          else
            false
          end
        end

      end


    end
  end
end


class PublishableEvent < ActiveRecord::Base
  
  belongs_to :publishable, :polymorphic => true
  belongs_to :user # the user that fired the event
  belongs_to :assigned_user, :class_name => 'User'
  
  named_scope :with_publishable_type, lambda {|t|  {:conditions => {:publishable_type => t}}  }

end
