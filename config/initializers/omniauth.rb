## need to add api permissions to so others can install in their store

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shopify,
           ShopifyApp.configuration.api_key,
           ShopifyApp.configuration.secret,
           :scope => "write_orders,write_products,write_shipping,write_fulfillments",
           :setup => lambda {|env|
                       params = Rack::Utils.parse_query(env['QUERY_STRING'])
                       site_url = "http://#{params['shop']}"#:3000"
                       env['omniauth.strategy'].options[:client_options][:site] = site_url
                     }
end