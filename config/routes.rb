Wukumurl::Application.routes.draw do
  get "map", :controller => 'map', :action => :index
  match "map/locations", :controller => 'map', :action => :location_list
  match "map/cities", :controller => 'map', :action => :city_list
  match "map/countries", :controller => 'map', :action => :country_list

  get "compare/index"

  match '/help' => 'help#index'

  match '/' => 'short_urls#create', :controller => 'short_urls', :via => :post

  match "/:short_name", :controller => 'short_urls', :action => :visit, :as => 'visit_short_url'

  #match '/compare/urls/:link1/:link2', :controller => 'compare', :action => :show_urls, :via => :get
  match '/compare/*tags' => "compare#index"

  resources :short_urls

  resources :organizations, only: [:destroy]

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'short_urls#visit'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
