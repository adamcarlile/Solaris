class Admin::PagesController < Admin::BaseController
  setup_resource_controller

  before_filter :require_page_editable_by_user, :only => [:edit,:update,:children]

  index.before do
    if params[:view] == 'list'
      @expand_ids = []
    else
      @expand_ids = @pages.map(&:id)
      if params[:reveal] and Page.exists?(params[:reveal])
        @expand_ids += Page.find(params[:reveal]).ancestors.map(&:id)
      end
      @expand_ids = @expand_ids.uniq.sort
      @page = Page.new
    end
  end
  
  index.response do |wants|
    wants.html { render :action => (params[:view] == 'list' ? 'index_list' : 'index') }
  end

  create.response do |wants|
    wants.html { redirect_to edit_object_url }
  end
  update.response do |wants|
    wants.html { redirect_to edit_object_url }
  end
  destroy.response do |wants|
    wants.html do
      if params[:return_to] == 'Children'
        redirect_to edit_admin_page_path(object.parent, :anchor => 'Children') 
      else
        redirect_to collection_url
      end
     end
  end

  def reorder_children
    load_object
    params[:pages].each do |page_id, attributes|
      @page.children.find(page_id).update_attribute(:position, attributes[:position])
    end
    redirect_to edit_admin_page_path(@page, :anchor => "Children")
  end


  def children
    load_object
    if @page.archive?
      @pages = @page.children.paginate(:page => params[:page], :order => 'publish_from DESC')
    else
      @pages = @page.children
    end
  end

  
  protected

    def collection_filters
      %w(type parent)
    end

    def collection
      if params[:view] == 'list'      
        paginate_collection_with_filters
      else
        Page.top_level
      end
    end

    def sitemap
      render :template => 'admin/pages/sitemap'
    end

    def build_object
        
      return @object unless @object.nil?

      if params[:page]
        # After submitting form, use parent from select field
        parent_id = params[:page][:parent_id]
      else
        # Initially use parent param if it exists to pre-populate page's parent
        parent_id = params[:parent]
      end
      if parent_id and Page.exists?(parent_id)
        @parent = Page.find(parent_id)
        @allowed_types = @parent.allowed_child_types
      else
        @allowed_types = [:folder]
      end    

      if !params[:type].blank?
        if @parent && @parent.allowed_child_types.include?(params[:type].to_sym)
          class_name = params[:type].camelize
        else
          class_name = 'BasicPage'
        end
      elsif @parent
        # Set the type based on the parent's type
        class_name = @parent.allowed_child_types.first.to_s.camelize
      else
        class_name = 'BasicPage'
      end
      
      @page = class_name.constantize.new(object_params)
      @page.parent = @parent if @parent
      
      @page.version_comment = 'Created page'

      @object = @page
    end




  private


    def require_page_editable_by_user
      access_denied unless object.editable_by?(current_user)
    end

    def require_page_publishable_by_user
      access_denied unless object.publishable_by?(current_user)
    end
    
end
