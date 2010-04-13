ActionController::Routing::Routes.draw do |map|

  map.namespace(:admin) do |admin|
    admin.resources :pages do |page|
      page.resources :panels, :collection => {:reorder => :post}
    end
  end

end
