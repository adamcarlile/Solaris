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
  
end