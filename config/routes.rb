Wukumurl::Application.routes.draw do
  get "map", :controller => 'map', :action => :index
  match "map/locations", :controller => 'map', :action => :location_list
  match "map/cities", :controller => 'map', :action => :city_list
  match "map/countries", :controller => 'map', :action => :country_list

  get "compare/index"

  match '/help' => 'help#index'

  match '/' => 'short_urls#create', :controller => 'short_urls', :via => :post

  match "/:short_name", :controller => 'short_urls', :action => :visit, :as => 'visit_short_url'
  match "/:short_name/info",
    :controller => 'short_urls',
    :action => :show,
    :as => 'short_url_info'

  match '/compare/*tags' => "compare#index"

  resources :short_urls

  resources :organizations, only: [:destroy]

  root :to => 'short_urls#visit'
end
