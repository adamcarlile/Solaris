class Flickr
  
  def initialize(flickr_id)
    @flickr_id = flickr_id
    @stream = set_stream
    ActiveRecord::Base.logger.info "Init flickr object for account #{@flickr_id}"
  end
  
  def stream
    @stream
  end
  
  def set_stream
  	 flickr.photos.search(:user_id => @flickr_id, :extras => "media")
  end
  
end