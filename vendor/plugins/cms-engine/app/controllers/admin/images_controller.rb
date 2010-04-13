class Admin::ImagesController < Admin::BaseController
  setup_resource_controller
  skip_before_filter :verify_authenticity_token
  require_role :writer

  def index
    @tags = Tag.with_type_scope(%w(Image)) { Tag.all }
    if params[:tag]
      if @tag = Tag.find_by_name(params[:tag])
        @images = @tag.taggings.with_type_scope(['Image']).paginate(:page => params[:page], :per_page => per_page)
        @images.replace(@images.map(&:taggable))
      end
    else
      @images = Image.with_keyword(params[:q]).paginate(:page => params[:page], :per_page => per_page)
    end
  end

  show.response do |wants|
    wants.html 
    wants.xml {render :action => 'show', :layout => false}
  end

  def crop_settings
    load_object
  end
  
  def flex_crop
    load_object
    if request.post?
      @image.update_attributes({
        :resize => params[:resize], 
        :crop_x => params[:crop_x], 
        :crop_y => params[:crop_y],
        :crop_w => params[:crop_w], 
        :crop_h => params[:crop_h]
        })
        @image.preview_latest_version
        @image.recreate_cropped_image
        render :text => @image.to_xml    
    else
      render :action => 'flex_crop', :layout => false
    end
  end
  
  protected

    def per_page
      100
    end

  private  
  
    def object_url
      admin_image_url(:popup => params[:popup])
    end

    def collection_url
      admin_images_url(:popup => params[:popup])
    end


end
