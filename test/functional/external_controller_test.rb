require 'test_helper'

class ExternalControllerTest < ActionController::TestCase
  def setup
    mock_shop_domain
    ExternalController.any_instance.stubs(:verify_shopify_request)
  end

  test "shipping_rates" do
    ShipwireApp::Application.config.shipwire_carrier_service_class.any_instance.expects(:find_rates).returns(shipping_rate_response)
    post :shipping_rates, shipping_rate_request_data
    assert_response :success
  end

  test "fetch_stock" do
    ExternalController.any_instance.expects(:verify_shopify_request).returns(true)
    ShipwireApp::Application.config.shipwire_fulfillment_service_class.any_instance.expects(:fetch_stock_levels).returns(stock_levels_response)
    post :fetch_stock, {:stock_levels => {:sku => 'abd', :shop => 'localhost'}}
    assert_response :success
  end

  test "fetch_tracking_numbers" do
    ShipwireApp::Application.config.shipwire_fulfillment_service_class.any_instance.expects(:fetch_tracking_numbers).returns(tracking_number_response)
    post :fetch_tracking_numbers, {:order_ids => [1,2,3]}
    assert_response :success
  end

  private

  def shipping_rate_request_data
    {:rate => {:items => [{:requires_shipping => true, :fulfillment_service => 'shipwire-app'}],
         :destination => {:country => "CA", :province => "ON", :city => "Ottawa", :address1 => "126 York St", :postal_code => "K1N 5T5"}}}
  end

  def mock_shop_domain
    ExternalController.any_instance.expects(:shop_domain).returns("localhost")
  end

  def tracking_number_response
    ActiveMerchant::Fulfillment::Response.new(true, "hello", {:tracking_numbers => [1,2,3]})
  end

  def stock_levels_response
    ActiveMerchant::Fulfillment::Response.new(true, "hello", {:stock_levels => {"qwe" => 123}})
  end

  def shipping_rate_response
    ActiveMerchant::Shipping::RateResponse.new(true, "hello", :options => {:rates => [stub(:service_name => 'Free!', :total_price => 0)], :xml => "<rate>Free!</rate>"})
  end

end
