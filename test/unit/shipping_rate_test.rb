require 'test/unit.rb'
require 'test_helper'

class ShippingRateTest < ActiveSupport::TestCase
  def setup
    FakeWeb.allow_net_connect = true
    session = ShopifyAPI::Session.new("http://localhost", "123")
    ShopifyAPI::Base.activate_session(session)

  end

  test "test_ShippingRates_find_rates" do
    #fake "admin/orders/18", :body => load_fixture('order18'), :method => :get,  :format => 'json', :base_url => 'http://localhost:3000/'
    destination = Destination.build_example
    rates = ShippingRates.new()
    rates.find_rates(destination, 133433068)#18)
    assert true
  end
end

