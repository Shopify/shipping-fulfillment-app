## need to add api permissions to so others can install in their store

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shopify,
           ShopifyApp.configuration.api_key,
           ShopifyApp.configuration.secret,
           :scope => "read_orders,write_products",
           :setup => lambda {|env|
                       params = Rack::Utils.parse_query(env['QUERY_STRING'])
                       site_url = "#{Rails.env.development? ? "http" : "https"}://#{params['shop']}:3000"
                       env['omniauth.strategy'].options[:client_options][:site] = site_url
                     }
end

if Rails.env.development?
  class ShopifyAPI::Session
    def site
      "http://#{url}:3000/admin"
    end
  end
end