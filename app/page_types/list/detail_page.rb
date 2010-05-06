class DetailPage < Page
  
  self.page_type_package = 'list'
  self.can_have_children = false
  self.can_have_comments = false
  self.show_in_nav       = false
  self.admin_template    = BasicPage.admin_template
  
end