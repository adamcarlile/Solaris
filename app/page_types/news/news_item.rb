CmsEngine.override_page_type :news_item, :news
class NewsItem < Page

  self.page_type_package = 'news'
  self.can_have_children = false
  self.can_have_comments = true
  self.show_in_nav       = false
  
  def self.latest(number = 10)
    published.most_recent_first.limit(number)
  end

end