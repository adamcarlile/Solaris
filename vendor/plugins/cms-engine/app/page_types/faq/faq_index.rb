class FaqIndex < Page

  self.page_type_package   = 'faq'
  self.admin_template      = BasicPage.admin_template
  self.allowed_child_types = [:question]

  def render(params)
    {:questions => children.published}
  end
  
end