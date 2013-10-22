Wukumurl::Application.routes.draw do
  get "map", :controller => 'map', :action => :index
  get "map/locations", :controller => 'map', :action => :location_list
  get "map/cities", :controller => 'map', :action => :city_list
  get "map/countries", :controller => 'map', :action => :country_list

  get "compare/index"

  get '/help' => 'help#index'

  match '/' => 'short_urls#create', :controller => 'short_urls', :via => :post

  get "/:short_name", :controller => 'short_urls', :action => :visit, :as => 'visit_short_url'
  get "/:short_name/info",
    :controller => 'short_urls',
    :action => :show,
    :as => 'short_url_info'

  get '/compare/*tags' => "compare#index"

  resources :short_urls

  resources :organizations, only: [:destroy]

  root :to => 'short_urls#visit'
end
