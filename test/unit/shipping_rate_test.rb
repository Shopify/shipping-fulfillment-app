require 'test/unit.rb'
require 'test_helper'

class ShippingRateTest < ActiveSupport::TestCase
  def setup
    super
    @order = create(:order, shop: @shop)
  end

  def destination(address)

    location = {
      country: address.country,
      province: address.province,
      city: address.city,
      address1: address.address1
    }

    ActiveMerchant::Shipping::Location.new(location)
  end

  def request_params
    {
      items:[
        {
          price: "10.00",
          name: "Draft - 151cm",
          title: "Draft",
          requires_shipping: true,
          quantity: 1,
          product_id: 108828309,
          id: 510711879,
          grams: 1500,
          sku: "draft-151",
          vendor: nil,
          variant_title: "151cm",
          fulfillment_status: nil,
          fulfilment_service: "shipwire",
          variant_id: 43729076
        }
      ],
      destination: {
        address1: "123 Amoebobacterieae St",
        name: "Bob Bobsen",
        city: "Ottawa",
        address2: "",
        address3: nil,
        company_name: "",
        country: "CA",
        postal_code: "K2P0V6",
        phone: "(555)555-5555",
        fax: nil,
        address_type: nil,
        province: "ON"
      },
      origin:{
        address1: "190 MacLaren Street",
        name: nil,
        city: "Ottawa",
        address2: nil,
        address3: nil,
        company_name: nil,
        country: "CA",
        postal_code: "K2P0L6",
        phone: nil,
        fax: nil,
        address_type: nil,
        province: "ON"
      },
      currency: "USD"
    }
  end

  def rate_return
    {
      total_price: 1744,
      service_code: '1D',
      delivery_date: DateTime.parse("Wed, 01 Aug 2012 00:00:00 +0000"),
      delivery_range: [DateTime.parse("Thu, 26 Jul 2012 00:00:00 +0000"), DateTime.parse("Wed, 01 Aug 2012 00:00:00 +0000")]
    }
  end

  test "find_rates for an order" do
    estimate = ActiveMerchant::Shipping::RateEstimate.new(nil, destination(@order.shipping_address), 'UPS', 'UPS Second Day Air', rate_return)
    ActiveMerchant::Shipping::Shipwire.any_instance.stubs(:find_rates).returns(stub(estimates: [estimate]))

    rates = ShippingRates.new(@shop.credentials, {id: @order.id}).fetch_rates
    assert_equal "17.44", rates.first[:price]
  end

  test "find_rates for a shopify request" do
    estimate = ActiveMerchant::Shipping::RateEstimate.new(nil, destination(@order.shipping_address), 'UPS', 'UPS Second Day Air', rate_return)
    ActiveMerchant::Shipping::Shipwire.any_instance.stubs(:find_rates).returns(stub(estimates: [estimate]))

    rates = ShippingRates.new(@shop.credentials, request_params).fetch_rates
    assert_equal "17.44", rates.first[:price]
  end
end