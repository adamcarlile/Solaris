class Admin::VersionsController < Admin::BaseController
  setup_resource_controller

  before_filter :require_page_editable_by_user, :only => [:index]
  before_filter :require_page_publishable_by_user, :only => [:publish, :revert]
  
  belongs_to :page, :image, :file_upload
  
  def per_page
    20
  end
  
  def publish
    parent_object.publish_version(object.version)
    flash[:notice] = "Published version #{object.version}"
    if parent_object.is_a?(Image)
      redirect_to parent_object_path
    else
      redirect_to edit_parent_object_path
    end
  end
  
  def revert
    load_object
    @page.current_user = current_user
    if @page.revert_to_version(object.version)
      flash[:notice] = "Reverted to version #{object.version}"
    else
      flash[:notice] = "Failed to revert, #{@page.revert_error}"
    end
    redirect_to edit_parent_object_path
  end

  private
      
    def model_name
      :version
    end

    def parent_object_path(extra_params = {})
      send("admin_#{parent_type}_path", parent_object, extra_params)
    end
    def edit_parent_object_path(extra_params = {})
      send("edit_admin_#{parent_type}_path", parent_object, extra_params)
    end
    helper_method :parent_object_path
    helper_method :edit_parent_object_path


    def require_page_editable_by_user
      access_denied unless parent_object.editable_by?(current_user)
    end

    def require_page_publishable_by_user
      access_denied unless parent_object.publishable_by?(current_user)
    end

end
