class Public::BannersController < Public::BaseController
  def index
    @collection = Banner.find(:all)
    respond_to do |format|
      format.html
      format.xml { render :template => 'public/banners/index.xml.builder', :layout => false }
    end  
  end
end
