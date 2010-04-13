ActionController::Routing::Routes.draw do |map|

  # Users
  map.resources :user_sessions
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.login '/login', :controller => 'user_sessions', :action => 'new'
  map.resources :users, :controller => 'public/users'
  map.signup '/signup', :controller => 'public/users', :action => 'new'
  map.signup_complete '/signup/complete', :controller => 'public/users', :action => 'complete'
  map.resources :password_resets
  

  # Admin Routes
  map.namespace(:admin) do |admin|
    admin.resources :pages, 
      :collection => {
        :sitemap => :get
        }, 
      :member => {
        :children => :get, :reorder_children => :put, :fire_event => :put
      } do |pages|
        pages.resources :attachments, :collection => {:reorder => :post, :search => :get, :batch_update => :put}
        pages.resources :versions, :member => {:revert => :put, :publish => :put}
        pages.resources :user_page_permissions
    end
    admin.resources :images, :member => {:crop_settings => :get} do |images|
      images.resources :versions, :member => {:revert => :put, :publish => :put}
    end
    admin.resources :file_uploads do |file_uploads|
      file_uploads.resources :versions, :member => {:revert => :put, :publish => :put}
    end
    admin.resources :file_upload_categories
    admin.resources :snippets
    admin.resources :users, :member => {:fire_event => :put}
    admin.resources :members, :member => { :suspend => :put, :unsuspend => :put }
    admin.resources :comments, :member => { :approve => :put }
    admin.resource :session
  end
  map.admin_dashboard 'admin', :controller => 'admin/dashboard', :action => 'index'
  map.flex_crop '/admin/images/:id/crop.xml', :controller => 'admin/images', :action => 'flex_crop', :format => 'xml'

  map.search 'search', :controller => 'public/search', :action => 'search', :method => :get
  map.enquiries 'enquiries', :controller => 'public/enquiries', :action => 'create', :method => :post
  map.comments 'comments', :controller => 'public/comments', :action => 'create', :method => :post
  map.tags 'tags', :controller => 'public/tags', :action => 'index'
  map.tags 'tags.:format', :controller => 'public/tags', :action => 'index'
  map.tag 'tags/:id', :controller => 'public/tags', :action => 'show'

  # All other pages
  map.with_options(:controller => 'public/pages') do |m|
    m.sitemap      'sitemap',                 :action => 'sitemap'
    m.sitemap      'sitemap.:format',         :action => 'sitemap'
    m.homepage     '',                        :action => 'view', :slug_path => 'home'
    m.view_page    '*slug_path.:format',      :action => 'view'
    m.view_page    '*slug_path',              :action => 'view'
  end

end
