require 'test_helper'
require 'net/http'

FakeWeb.allow_net_connect = true

class WebhooksControllerTest < ActionController::TestCase


  # test "order is fulfilled if automatic fulfillment true" do
  #   WebhooksController.any_instance.stubs(:verify_webhook).returns(true)
  #   Setting.expects(:where).with("myshop1").returns(setting:{automatic_fulfillment:true, token: '555666'})
  #   ShopifyAPI::Session.stubs(:new)
  #   Fulfillment.expects(:fulfill)

  #   address = 'http://shipwireapp:3001/orderpaid'
  #   uri = URI.parse(address)
  #   http = Net::HTTP.new(uri.host, uri.port) 
  #   data = "{\"buyer_accepts_marketing\":true,\"cancel_reason\":null,\"cancelled_at\":null,\"cart_token\":\"8b68cb8b762aa43c21c020d52f6fd040\",\"closed_at\":null,\"created_at\":\"2012-06-27T13:16:17-04:00\",\"currency\":\"CAD\",\"email\":\"david.thomas@shopify.com\",\"financial_status\":\"paid\",\"fulfillment_status\":null,\"gateway\":\"Cash on Delivery (COD)\",\"id\":31,\"landing_site\":\"/\",\"name\":\"#1025\",\"note\":\"\",\"number\":25,\"referring_site\":\"http://localhost:3000/orders/1/fa08c0e7a4aca162d1f38568d9608e5e\",\"subtotal_price\":\"30.00\",\"taxes_included\":false,\"token\":\"d4242fc931b449f9a6a610a58ecd78b8\",\"total_discounts\":\"0.00\",\"total_line_items_price\":\"30.00\",\"total_price\":\"50.00\",\"total_price_usd\":null,\"total_tax\":\"0.00\",\"total_weight\":3000,\"updated_at\":\"2012-06-27T13:17:16-04:00\",\"browser_ip\":null,\"landing_site_ref\":null,\"order_number\":1025,\"discount_codes\":[],\"note_attributes\":[],\"processing_method\":\"manual\",\"line_items\":[{\"fulfillment_service\":\"shipwire\",\"fulfillment_status\":null,\"grams\":1000,\"id\":48,\"price\":\"10.00\",\"product_id\":3,\"quantity\":3,\"requires_shipping\":true,\"sku\":\"GN-600-46\",\"title\":\"Basketball\",\"variant_id\":2,\"variant_title\":null,\"vendor\":\"Spalding\",\"name\":\"Basketball\",\"variant_inventory_management\":\"shopify\"}],\"shipping_lines\":[{\"code\":\"International Shipping\",\"price\":\"20.00\",\"source\":\"shopify\",\"title\":\"International Shipping\"}],\"tax_lines\":[],\"billing_address\":{\"address1\":\"7318 Black Swan Place\",\"address2\":\"\",\"city\":\"Carlsbad\",\"company\":\"\",\"country\":\"United States\",\"first_name\":\"David\",\"last_name\":\"Thomas\",\"latitude\":\"45.416311\",\"longitude\":\"-75.68683\",\"phone\":\"\",\"province\":\"American Samoa\",\"zip\":\"92011\",\"name\":\"David Thomas\",\"country_code\":\"US\",\"province_code\":\"AS\"},\"shipping_address\":{\"address1\":\"7318 Black Swan Place\",\"address2\":\"\",\"city\":\"Carlsbad\",\"company\":\"\",\"country\":\"United States\",\"first_name\":\"David\",\"last_name\":\"Thomas\",\"latitude\":\"45.416311\",\"longitude\":\"-75.68683\",\"phone\":\"\",\"province\":\"American Samoa\",\"zip\":\"92011\",\"name\":\"David Thomas\",\"country_code\":\"US\",\"province_code\":\"AS\"},\"fulfillments\":[],\"customer\":{\"accepts_marketing\":true,\"created_at\":\"2012-06-18T09:47:02-04:00\",\"email\":\"david.thomas@shopify.com\",\"first_name\":\"David\",\"id\":1,\"last_name\":\"Thomas\",\"last_order_id\":31,\"note\":null,\"orders_count\":19,\"state\":\"disabled\",\"total_spent\":\"896.00\",\"updated_at\":\"2012-06-27T13:17:16-04:00\",\"tags\":\"\",\"last_order_name\":\"#1025\"}}"
  #   headers = {"Content-Type"=>"application/json", "X-Shopify-Topic"=>"orders/paid", "X-Shopify-Shop-Domain"=>"myshop1", "X-Shopify-Order-Id"=>"31", "X-Shopify-Test"=>"false", "X-Shopify-Hmac-SHA256"=>"N29mY/AE89Xkzg/cPX9JFApv/BYLT1nNyRTWPYMG0L4="}
  #   response = http.post(address, data, headers)
  #   puts "response: #{response.inspect}"
    
  #   assert_response 200
  # end

  # test "order is not fulfilled if automatic fulfillment false" do
  #   WebhooksController.any_instance.stubs(:verify_webhook).returns(true)
  #   ShopifyAPI::Session.expects(:new)
  #   Fulfillment.expects(:fulfill)

  #   address = 'http://shipwireapp:3001/orderpaid'
  #   uri = URI.parse(address)
  #   http = Net::HTTP.new(uri.host, uri.port) 
  #   data = "{\"buyer_accepts_marketing\":true,\"cancel_reason\":null,\"cancelled_at\":null,\"cart_token\":\"8b68cb8b762aa43c21c020d52f6fd040\",\"closed_at\":null,\"created_at\":\"2012-06-27T13:16:17-04:00\",\"currency\":\"CAD\",\"email\":\"david.thomas@shopify.com\",\"financial_status\":\"paid\",\"fulfillment_status\":null,\"gateway\":\"Cash on Delivery (COD)\",\"id\":31,\"landing_site\":\"/\",\"name\":\"#1025\",\"note\":\"\",\"number\":25,\"referring_site\":\"http://localhost:3000/orders/1/fa08c0e7a4aca162d1f38568d9608e5e\",\"subtotal_price\":\"30.00\",\"taxes_included\":false,\"token\":\"d4242fc931b449f9a6a610a58ecd78b8\",\"total_discounts\":\"0.00\",\"total_line_items_price\":\"30.00\",\"total_price\":\"50.00\",\"total_price_usd\":null,\"total_tax\":\"0.00\",\"total_weight\":3000,\"updated_at\":\"2012-06-27T13:17:16-04:00\",\"browser_ip\":null,\"landing_site_ref\":null,\"order_number\":1025,\"discount_codes\":[],\"note_attributes\":[],\"processing_method\":\"manual\",\"line_items\":[{\"fulfillment_service\":\"shipwire\",\"fulfillment_status\":null,\"grams\":1000,\"id\":48,\"price\":\"10.00\",\"product_id\":3,\"quantity\":3,\"requires_shipping\":true,\"sku\":\"GN-600-46\",\"title\":\"Basketball\",\"variant_id\":2,\"variant_title\":null,\"vendor\":\"Spalding\",\"name\":\"Basketball\",\"variant_inventory_management\":\"shopify\"}],\"shipping_lines\":[{\"code\":\"International Shipping\",\"price\":\"20.00\",\"source\":\"shopify\",\"title\":\"International Shipping\"}],\"tax_lines\":[],\"billing_address\":{\"address1\":\"7318 Black Swan Place\",\"address2\":\"\",\"city\":\"Carlsbad\",\"company\":\"\",\"country\":\"United States\",\"first_name\":\"David\",\"last_name\":\"Thomas\",\"latitude\":\"45.416311\",\"longitude\":\"-75.68683\",\"phone\":\"\",\"province\":\"American Samoa\",\"zip\":\"92011\",\"name\":\"David Thomas\",\"country_code\":\"US\",\"province_code\":\"AS\"},\"shipping_address\":{\"address1\":\"7318 Black Swan Place\",\"address2\":\"\",\"city\":\"Carlsbad\",\"company\":\"\",\"country\":\"United States\",\"first_name\":\"David\",\"last_name\":\"Thomas\",\"latitude\":\"45.416311\",\"longitude\":\"-75.68683\",\"phone\":\"\",\"province\":\"American Samoa\",\"zip\":\"92011\",\"name\":\"David Thomas\",\"country_code\":\"US\",\"province_code\":\"AS\"},\"fulfillments\":[],\"customer\":{\"accepts_marketing\":true,\"created_at\":\"2012-06-18T09:47:02-04:00\",\"email\":\"david.thomas@shopify.com\",\"first_name\":\"David\",\"id\":1,\"last_name\":\"Thomas\",\"last_order_id\":31,\"note\":null,\"orders_count\":19,\"state\":\"disabled\",\"total_spent\":\"896.00\",\"updated_at\":\"2012-06-27T13:17:16-04:00\",\"tags\":\"\",\"last_order_name\":\"#1025\"}}"
  #   headers = {"Content-Type"=>"application/json", "X-Shopify-Topic"=>"orders/paid", "X-Shopify-Shop-Domain"=>"myshop2", "X-Shopify-Order-Id"=>"31", "X-Shopify-Test"=>"false", "X-Shopify-Hmac-SHA256"=>"N29mY/AE89Xkzg/cPX9JFApv/BYLT1nNyRTWPYMG0L4="}
  #   response = http.post(address, data, headers)
  #   puts "response: #{response.inspect}"
    
  #   assert_response 500
  # end

  # test "" do
  #   assert true
  # end
end
