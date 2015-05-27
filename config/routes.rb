Wukumurl::Application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'sessions',
    registrations: 'registrations',
    confirmations: 'confirmations',
    passwords: 'passwords'
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

  match '/' => 'short_urls#create', :controller => 'short_urls', :via => :post

  namespace :admin do
    resources :dashboard, :only => [:index]
  end

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
  resources :users, only: [:update]
  resources :teams, only: [:show]

  authenticate :user do
    get '/users/my_links', to: 'users#show', as: 'user_links'
    get '/users/pick_team', to: 'users#pick_team', as: 'pick_team'
  end

  root to: 'short_urls#index', as: :root
end
