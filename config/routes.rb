Wukumurl::Application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'sessions',
    registrations: 'registrations'
  }

  devise_scope :user do
    get "login", to: "devise/sessions#new"
    post "login", to: "devise/sessions#create"

    get "logout", to: "devise/sessions#destroy"

    get "register", to: "devise/registrations#new"
    post "register", to: "devise/registrations#create"

    get "forgot_password", to: "devise/passwords#new"
    post "forgot_password", to: "devise/passwords#create"
  end

  get "map", :controller => 'map', :action => :index
  get "map/locations", :controller => 'map', :action => :location_list
  get "map/cities", :controller => 'map', :action => :city_list
  get "map/countries", :controller => 'map', :action => :country_list

  get '/help' => 'help#index'

  match '/' => 'short_urls#create', :controller => 'short_urls', :via => :post

  get "/short_urls/list",
    :controller => 'short_urls',
    :action => :list
  resources :short_urls

  get "/:short_name", :controller => 'short_urls', :action => :visit, 
    :as => 'visit_short_url'
  get "/:short_name/info",
    :controller => 'short_urls',
    :action => :show,
    :as => 'short_url_info'

  resources :organizations, only: [:destroy]

  authenticated :user do
    root to: 'users#show', as: :authenticated_root
  end

  root to: 'short_urls#index', as: :root
end
