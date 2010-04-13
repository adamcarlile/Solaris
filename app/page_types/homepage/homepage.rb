class Homepage < Page

  self.can_have_children = false
  self.page_layout = 'homepage'
  
  def render(params)
    {
      :panels => self.panels
    }
  end
  
end