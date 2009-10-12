ActionController::Routing::Routes.draw do |map|
  map.resources :comments
  map.resources :posts

  map.root :controller => :posts, :action => :index
end
