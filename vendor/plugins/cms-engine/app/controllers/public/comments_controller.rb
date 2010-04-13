class Public::CommentsController < Public::BaseController

  def create
    @comment = Comment.new(params[:comment])
    @comment.ip = request.remote_ip
    if can_create_comment?
      if @comment.save
        flash[:notice] = 'Thank you for your comment. It will appear on the site when it has been approved'
      else
        flash[:error] = 'Failed to add comment, please check the details you entered'
      end
    end
    redirect_to url_for_page(@comment.commentable)
  end

  private

    # Perform necesary checks to make sure a comment is allowed
    # Override as necessary to add additional checks or disable captcha
    def can_create_comment?
      unless @comment.ip_can_comment?
        flash[:error] = 'Sorry, comments are limited to 1 per hour'
        return false
      end
      ENV['RAILS_ENV'] == 'cucumber' || verify_recaptcha(@comment)
    end

end