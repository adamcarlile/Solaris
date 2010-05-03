class ProfileIndex < Page

  self.page_type_package   = 'profile'
  self.admin_template      = BasicPage.admin_template
  self.allowed_child_types = [:profile]
  
  def render(params)
  {
    :profiles => children.published
  }
  end
  
end
