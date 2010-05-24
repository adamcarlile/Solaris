class VideoIndex < Page

  self.page_type_package   = 'videos'
  self.archive             = true
  self.admin_template      = 'basic_page/views/admin/basic_page'
  self.extra_path_params   = [:video_id]
  
  def render(params) 
    scope = Video.state('converted')
    values = {}
    if params[:video_id]
      values[:first_video] = scope.find_by_id(params[:video_id])
    else
      values[:first_video] = scope.first
    end
    values[:latest] = scope.limit(5)
    values[:all_videos] = scope.paginate(:per_page => 5, :page => params[:page])
    values
  end

end