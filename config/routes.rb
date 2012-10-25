ShipwireApp::Application.routes.draw do

  #resource routes

  resource :shop, :except => [:index, :destroy]

  resources :fulfillments, :only => [:index, :show]

  #external routes

  match "external/shipping_rates" => "external#shipping_rates", :via => :post #Consider removing the external

  match "fetch_stock" => "external#fetch_stock", :via => [:get, :post]

  match "fetch_tracking_numbers" => "external#fetch_tracking_numbers", :via => :post


  #webhook routes

  match "fulfillmentscreate" => "webhooks#fulfillment", :via => :post
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