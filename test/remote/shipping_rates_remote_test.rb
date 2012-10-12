require 'test_helper'

FakeWeb.allow_net_connect = true

class ShippingRatesRemoteTest < ActiveSupport::TestCase

  def setup
    @credentials = {:login => 'pixels@jadedpixel.com',
                    :password => 'Ultimate'}
    @params = {:items => [{:sku => 'AF0001', :quantity => 3, :fulfillment_service => 'shipwire-app', :requires_shipping => true}],
               :destination => {:country => 'US', :province => 'CA', :postal_code => '90210'}}
  end

  test 'Rates should be fetched from Shipwire' do
    rates = ShippingRates.new(@credentials, @params).fetch_rates

    assert !rates.empty?
  end

  test 'error thrown for bad sku' do
    @params[:items].first[:sku] = "BAD_SKU"
    assert_raises(ActiveMerchant::Shipping::ResponseError) do
      ShippingRates.new(@credentials, @params).fetch_rates
    end
  end
end