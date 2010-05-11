class Gallery < Page

  self.admin_template    = BasicPage.admin_template
  self.can_have_children = false
  self.can_have_comments = false
  
end