class Public::EventsController < CMSController
    
  def create
    respond_to do |wants|
      wants.js do
        if current_user
          class_type = params[:class_type].camelize
          logger.debug "Created event: #{current_user.id}, #{class_type}, #{params[:event_type]}, #{params[:eventable_id]}"
          @event = Event.new(:user_id => current_user.id, :event_type => params[:event_type], :eventable_id => params[:eventable_id], :eventable_type => class_type )
          @event.save
          render :text => '200, Event Logged', :status => 200
        else
          render :text => '403, Current user not logged in', :status => 403
        end
      end
    end
  end
  
end
