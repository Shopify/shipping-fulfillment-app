require 'test/unit.rb'
require 'test_helper'
require 'date'

class ShippingRateTest < ActiveSupport::TestCase
  def setup
    FakeWeb.allow_net_connect = true
    session = ShopifyAPI::Session.new("http://localhost", "123")
    ShopifyAPI::Base.activate_session(session)

  end

  test "find_rates" do
    fake "admin/orders/18", :body => load_fixture('order18'), :method => :get,  :format => 'json'
    date = DateTime.now.to_date
    estimate = stub(:estimates => [stub({:total_price => 50, :service_name => 'UPS Ground', :service_code => 'GD', :delivery_date => date + 7, :delivery_range => [date + 1, date + 7]})])
    ActiveMerchant::Shipping::Shipwire.any_instance.expects(:find_rates).returns(estimate)
    ## must turn caching off
    ShippingRates.stubs(:rates_cache_key).returns('new')

    rates = ShippingRates.find_order_rates(18)
    puts rates.inspect
    assert true
  end
end
