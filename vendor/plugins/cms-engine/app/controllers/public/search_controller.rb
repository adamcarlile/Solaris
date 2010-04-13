class Public::SearchController < Public::BaseController

  def search
    @q = params[:q].to_s.strip
    @results = SearchIndex.search(@q, :page => params[:page], :per_page => 10)
  end

end