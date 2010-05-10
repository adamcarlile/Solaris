class PressRelease < Page

  self.page_type_package = 'news'
  self.can_have_children = false
  self.can_have_comments = false
  self.show_in_nav       = false
  
  def self.latest(number = 10)
    published.most_recent_first.limit(number)
  end

end