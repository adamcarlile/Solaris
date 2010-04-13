class Public::PagesController < Public::BaseController

  def view
    load_page
    render_not_found and return unless @page and @page.visitable?
    redirect_to login_url and return if @page.restricted? and !logged_in?
    redirect_to @page.url and return if @page.is_a?(Redirect)
    render_page
  end
  
  protected

    def object
      @page || load_page
    end
    helper_method :object
     
end