class Question < Page
  
  self.page_type_package = 'faq'
  self.can_have_children = false
  self.visitable         = false
  self.show_in_nav       = false
  
  alias_attribute :answer, :body

end