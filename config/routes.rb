ShipwireApp::Application.routes.draw do

  #TODO Routing

  resource :shop #, :except => [:index, :destroy]

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

  match "orderpaid" => "webhooks#create", :via => :post

  match "ordercancelled" => "webhooks#create", :via => :post

  match "orderfulfilled" => "webhooks#create", :via => :post

  match "ordercreated" => "webhooks#create", :via => :post

  match "orderupdated" => "webhooks#create", :via => :post

  match 'auth/shopify/callback' => 'login#finalize'

  match 'login'              => 'login#index',        :as => :login

  match 'login/authenticate' => 'login#authenticate', :as => :authenticate

  match 'login/finalize'     => 'login#finalize',     :as => :finalize

  match 'login/logout'       => 'login#logout',       :as => :logout

  root :to                   => 'login#index'

  mount Resque::Server, :at =>  '/resque' if Rails.env == 'development'
end
