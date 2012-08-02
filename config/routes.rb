ShipwireApp::Application.routes.draw do

  #TODO Routing

  #resource routes

  resource :shop, :except => [:new, :edit, :destroy]

  resources :fulfillments, :only => [:index, :show, :create]

  resources :orders, :only => [:index, :show] 

  resources :variants, :except => [:update, :new, :edit]

  match "shippingrates" => "orders#shipping_rates",   :as => :rates

  #external routes

  match "external/shipping_rates" => "external#shipping_rates", :via => :post

  #webhook routes

  match "orderpaid" => "webhooks#create", :via => :post

  match "ordercancelled" => "webhooks#create", :via => :post

  match "orderfulfilled" => "webhooks#create", :via => :post

  match "ordercreated" => "webhooks#create", :via => :post

  match "orderupdated" => "webhooks#create", :via => :post

  #login routes

  match 'auth/shopify/callback' => 'login#finalize'

  match 'login'              => 'login#index',        :as => :login

  match 'login/authenticate' => 'login#authenticate', :as => :authenticate

  match 'login/finalize'     => 'login#finalize',     :as => :finalize

  match 'login/logout'       => 'login#logout',       :as => :logout

  #other routes

  root :to                   => 'login#index'

  mount Resque::Server, :at =>  '/resque' if Rails.env == 'development'

end