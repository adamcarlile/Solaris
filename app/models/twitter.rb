include HTTParty
class Twitter
  
  base_uri 'api.twitter.com'

  def initialize(u, p)
    @auth = {:username => u, :password => p}
    ActiveRecord::Base.logger.info "Initialize twitter HTTParty object for account #{@auth[:username]}"
  end

  def timeline(which=:friends, options = {})
    options = {:basic_auth => @auth}.update(options)
    self.class.get("/statuses/#{which}_timeline.json", options)
  end

end