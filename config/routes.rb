ActionController::Routing::Routes.draw do |map|

  map.namespace(:admin) do |admin|
    admin.resources :pages do |page|
      page.resources :panels, :collection => {:reorder => :post}
    end
    
    admin.resources :users, :member => {:fire_event => :put, :download_log => :get}
  end
  
  map.event '/event/:class_type/:event_type/:eventable_id', :controller => 'public/events', :action => 'create'
  map.event '/event/:class_type/:event_type/:eventable_id.:format', :controller => 'public/events', :action => 'create'

end
