class ListIndex < Page
  
  self.page_type_package   = 'list'
  self.can_have_children   = true
  self.allowed_child_types = [:detail_page]
  self.can_have_comments   = false
  self.admin_template      = BasicPage.admin_template
  
  def render(params)
    {
      :items => children.published
    }
  end
  
end