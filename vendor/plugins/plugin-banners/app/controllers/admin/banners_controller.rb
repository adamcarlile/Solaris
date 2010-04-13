class Admin::BannersController < Admin::BaseController
  setup_resource_controller
  
  def sort
    params[:banner].each_with_index do |id, index|
      Banner.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true, :status => 200
  end
  
end
