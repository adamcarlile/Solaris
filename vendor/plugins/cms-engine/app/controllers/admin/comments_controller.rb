class Admin::CommentsController < Admin::BaseController
  setup_resource_controller
  
  require_role :editor
  

  def index
    @comments = Comment.pending_approval.paginate(:page => params[:page])
  end
  
  def approve
    object.approve!
    flash[:notice] = 'Comment approved'
    redirect_to collection_path
  end
  
  private

end
