require 'test_helper'

class CreateFulfillmentJobTest < ActiveSupport::TestCase

  setup do
    @shop = shops(:david)
    @order_response = mock_order_response
    @example_fulfillment = ActiveSupport::JSON.decode(File.read('test/data/example_fulfillment.json'))
    @shipwire_service = ShipwireApp::Application.config.shipwire_fulfillment_service_class.new(@shop.credentials)
    @response = ActiveMerchant::Fulfillment::Response.new(true, "success")
    @fulfillment = mock("ShopifyAPI::Fulfillment")
  end

  test 'fulfillments with valid skus should be successfully fulfilled' do
    ShopifyAPI::Session.expects(:temp).twice.yields
    ShopifyAPI::Order.expects(:find).returns(@order_response)
    @order_response.expects(:shipping_address).returns(mock_address)
    ShopifyAPI::Fulfillment.expects(:find).returns(@fulfillment)
    @fulfillment.expects(:complete)

    ShipwireApp::Application.config.shipwire_fulfillment_service_class.expects(:new).returns(@shipwire_service)
    @shipwire_service.expects(:fulfill).returns(@response)

    CreateFulfillmentJob.perform(@example_fulfillment, @shop.domain)
    
  end

  private

  def mock_order_response
    mock('ShopifyAPI::Order - Response') do
      stubs(:id => 1, :email => "test@test.com")
    end
  end

  def mock_address
    mock('Shopify Order Address') do
      stubs(:address1 => "blag",
            :address2 => "blag",
            :name => "blag",
            :company => "blag",
            :city => "blag",
            :province => "blag",
            :country => "blag",
            :zip => "blag",
            :phone => "blag")
    end
  end

end