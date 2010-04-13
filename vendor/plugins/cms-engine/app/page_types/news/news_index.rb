class NewsIndex < Page

  self.page_type_package   = 'news'
  self.archive             = true
  self.admin_template      = 'basic_page/views/admin/basic_page'
  self.allowed_child_types = [:news_item]
  self.extra_path_params   = [:year, :month]

  def latest_stories(number = 10)
    children.published.most_recent_first.limit(number)
  end
  
  def render(params)
    scope = children.published.most_recent_first
    values = {}
    if params[:year] && params[:month] && date_range = NewsIndex.date_range_for_month(params[:year], params[:month])
      scope = scope.in_date_range(date_range)
      values[:date_range] = date_range
    end
    values[:news_items] = scope.paginate(:page => params[:page])
    values
  end

  # Return a range that covers all dates in the supplied year and month
  # or nil if year and month are invalid
  def self.date_range_for_month(year, month)
    begin
      date = Date.new(year.to_i, month.to_i)
    rescue ArgumentError
      return nil
    end
    (date .. (date + 1.month - 1.day))
  end

  def self.archive_months
    months = NewsItem.connection.select_all( %(SELECT DISTINCT DATE_FORMAT(created_at, '%m') AS month, DATE_FORMAT(created_at, '%Y') AS year FROM pages WHERE type = 'NewsItem' AND (#{CmsEngine::Acts::Publishable::PUBLISHED_CONDITIONS}) ORDER BY created_at DESC LIMIT 10) )
    months.map{|m| {:year => m["year"].to_i, :month => m["month"].to_i }}
  end
  
end