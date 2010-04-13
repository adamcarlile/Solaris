class Admin::DashboardController < Admin::BaseController

  def index
    @pages_pending_review = Page.with_state(:pending_review)
    unless current_user.has_role?(:editor)
      @pages_pending_review = @pages_pending_review.editable_by(current_user)
    end
    @pages_assigned_to_current_user = current_user.assigned_publishable_events
    @assigned_publishable_events = current_user.assigned_publishable_events.with_publishable_type('Page').paginate(:per_page => 10, :page => params[:page])
  end
  
end
