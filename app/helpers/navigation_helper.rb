require File.join('vendor/plugins/cms-engine/app/helpers/navigation_helper')
module NavigationHelper
  
  def render_breadcrumb
    return '' if breadcrumbs.empty?
    elements = breadcrumbs.map do |crumb|
      if crumb.second
        content_tag('li', link_to(crumb.first, crumb.second)) + content_tag('li', '/')
      else
        content_tag('li', content_tag('span', crumb.first))
      end
    end
	  content_tag('ul', elements.join, :id => 'breadcrumb')
  end
  
  def link_to_page(page, prefix = '')
    subtitle = ''
    unless page.subtitle.nil? || page.subtitle.empty?
      subtitle = content_tag('span', page.subtitle)
    end 
    content = h(page.nav_title) + subtitle
    link_to(prefix + content, url_for_page(page))
  end
  
end