ShipwireApp::Application.routes.draw do
  resource :setting #, :except => [:index, :destroy]

  resources :variants do
    member do
      get '/inventory', :action => :fetch_inventory
    end
  end


  resources :fulfillments

  resources :orders do
    collection do
      get '/page/:page', :action => :index
    end
    member do
      get '/page/:page', :action => :show
    end
  end

  match "shippingrates" => "orders#shipping_rates",   :as => :rates

  match "orderpaid" => "webhooks#order_paid", :via => :post

  match "ordercancelled" => "webhooks#order_updated", :via => :post

  match "orderfulfilled" => "webhooks#order_fulfilled", :via => :post

  match "ordercreated" => "webhooks#order_created", :via => :post

  match "orderupdated" => "webhooks#order_updated", :via => :post

  match 'auth/shopify/callback' => 'login#finalize'

  match 'login'              => 'login#index',        :as => :login

  match 'login/authenticate' => 'login#authenticate', :as => :authenticate

  match 'login/finalize'     => 'login#finalize',     :as => :finalize

  match 'login/logout'       => 'login#logout',       :as => :logout

  match 'variants/sync'     => 'variants#sync'

  root :to                   => 'login#index'

  #only for development environment
  mount Resque::Server, :at =>  '/resque'

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
