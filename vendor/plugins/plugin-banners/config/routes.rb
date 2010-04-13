ActionController::Routing::Routes.draw do |map|
  map.namespace(:admin) do |admin|
    admin.resources :banners, :collection => {:sort => :post}
  end
  
  map.resources :banners, :controller => 'public/banners'
end
