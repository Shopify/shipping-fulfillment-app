require 'test/unit.rb'
require 'test_helper'

class ShippingRateTest < ActiveSupport::TestCase
  def setup
    Shop.any_instance.expects(:setup_webhooks)
    Shop.any_instance.expects(:set_domain)

    @shop = create(:shop)
    @order = create(:order, shop: @shop)
  end

  def destination(address)

    location = {
      country: address.country,
      province: address.province,
      city: address.city,
      name: nil,
      address1: address.address1,
      address2: nil,
      address3: nil,
      phone: nil,
      fax: nil,
      company: nil
    }

    ActiveMerchant::Shipping::Location.new(location)
  end

  test "Find_rates" do
    options = {
      total_price: 1744,
      service_code: '1D',
      delivery_date: DateTime.parse("Wed, 01 Aug 2012 00:00:00 +0000"),
      delivery_range: [DateTime.parse("Thu, 26 Jul 2012 00:00:00 +0000"), DateTime.parse("Wed, 01 Aug 2012 00:00:00 +0000")]
    }
    estimate = ActiveMerchant::Shipping::RateEstimate.new(nil, destination(@order.shipping_address), 'UPS', 'UPS Second Day Air', options)
    ActiveMerchant::Shipping::Shipwire.any_instance.stubs(:find_rates).returns(stub(estimates: [estimate]))

    rates = ShippingRates.find_order_rates(@shop, @order.id)
    assert_equal rates.first[:price], "17.44"
  end
end