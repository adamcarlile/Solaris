class Public::EnquiriesController < Public::BaseController

  def create
    load_page
    render_not_found and return unless @page and @page.visitable?
    @enquiry = Enquiry.new(:source => @page.title)
    if request.post?
      @enquiry.attributes = params[:enquiry]
      if @enquiry.valid? && (ENV['RAILS_ENV'] == 'cucumber' || verify_recaptcha(@enquiry))
        @enquiry.save
        redirect_to url_for_page(@page, :sent => 1) and return
      else
        flash.now[:error] = 'Please check the details you provided'
        render_page
      end
    end
  end

end