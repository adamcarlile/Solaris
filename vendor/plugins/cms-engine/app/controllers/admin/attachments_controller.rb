class Admin::AttachmentsController < Admin::BaseController
  setup_resource_controller
  belongs_to :page
  
  index.before do
    @tags = Tag.with_type_scope(%w(Image FileUpload)) { Tag.all }
  end
  
  # Creates a new attachment either from newly uploaded file or from existing attachable item
  def create
    @page = parent_object
    # Before adding a new attachment to the collection, build attachments to match the latest version
    @page.build_attachments_from_version(@page.latest_version)
    @object = @attachment = @page.attachments.build(object_params)

    # If uploading new file
    if params[:attachable]
      @klass = @attachment.attachable_type.constantize
      @attachable = @klass.create(params[:attachable])
      @attachment.attachable = @attachable
    end
  
    @page.version_comment = "Added new attachment (#{@attachment.attachable.class})"

    if object.valid? && @page.save # save the page, not the attachment so versioning works correctly
      @page.preview_latest_version
      respond_to do |wants|
        wants.html { redirect_to edit_admin_page_path(@page, :anchor => "Attachments") }
        wants.js { render :action => "create" }
      end
    else
      after :create_fails
      set_flash :create_fails
      response_for :create_fails
    end
  end

  def batch_update
    @page = parent_object
    @page.version_comment = "Edited attachments"

    @page.preview_latest_version
    @page.update_attributes(params[:page])
    @page.preview_latest_version

    respond_to do |wants|
      wants.html { redirect_to collection_url }
      wants.js { render :action => "batch_update" }
    end
  end
  
  def search
    @page = parent_object
    params[:type] ||= 'image'
    @klass = params[:type].camelize.constantize

    if params[:tag]
      if @tag = Tag.find_by_name(params[:tag])
        @content_items = @tag.taggings.with_type_scope(['Image', 'FileUpload']).paginate(:page => params[:page], :per_page => 20)
        @taggables = @content_items.map(&:taggable)
        @content_items.replace(@taggables)
      end
    else
      scope = @klass.with_keyword(params[:q])
      @content_items = @klass.with_keyword(params[:q]).paginate(:page => params[:page], :per_page => 20)
    end
  end
  
end
