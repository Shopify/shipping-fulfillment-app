ShipwireApp::Application.routes.draw do

  #resource routes

  resource :shop, :except => [:index, :destroy]

  resources :fulfillments, :only => [:index, :show]

  # resources :orders, :only => [:index, :show]

  # resources :variants, :except => [:update, :new, :edit] do
  #   collection do
  #     match "/filter/:management/:page" => "variants#index", :via => :get
  #     match "/filter/:management" => "variants#index", :via => :get
  #   end
  # end

  # match "variants/update" =>  "variants#update", :as => :variant_update, :via => :post

  # match "shippingrates" => "orders#shipping_rates",   :as => :rates

  #external routes

  match "external/shipping_rates" => "external#shipping_rates", :via => :post #Consider removing the external

  match "fetch_stock" => "external#fetch_stock", :via => [:get, :post]

  match "fetch_tracking_numbers" => "external#fetch_tracking_numbers", :via => :post


  #webhook routes

  # match "orderpaid" => "webhooks#order", :via => :post

  # match "ordercancelled" => "webhooks#order", :via => :post

  # match "orderfulfilled" => "webhooks#order", :via => :post

  # match "ordercreated" => "webhooks#order", :via => :post

  # match "orderupdated" => "webhooks#order", :via => :post

  match "fulfillmentcreated" => "webhooks#fulfillment", :via => :post
  match "appuninstalled" => "webhooks#uninstalled", :via => :post

  #login routes

  match 'auth/shopify/callback' => 'login#finalize'

  match 'login'              => 'login#index',        :as => :login

  match 'login/authenticate' => 'login#authenticate', :as => :authenticate

  match 'login/finalize'     => 'login#finalize',     :as => :finalize

  match 'login/logout'       => 'login#logout',       :as => :logout

  #other routes

  match 'test' => 'external#fulfill_order', :via => :post #TODO REMOVE

  root :to                   => 'shops#show'

  mount Resque::Server, :at =>  '/resque' if Rails.env == 'development'

end