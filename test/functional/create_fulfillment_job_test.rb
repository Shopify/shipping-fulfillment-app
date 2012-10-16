require 'test_helper'

class CreateFulfillmentJobTest < ActiveSupport::TestCase

  setup do
    @shop = shops(:david)
    @order_response = mock_order_response
    @example_fulfillment = ActiveSupport::JSON.decode(File.read('test/data/example_fulfillment.json'))
    @shipwire_service = ActiveMerchant::Fulfillment::ShipwireService.new(@shop.credentials)
    @response = ActiveMerchant::Fulfillment::Response.new(true, "success")
    @fulfillment = mock_fulfillment
  end

  test 'fulfillments with valid skus should be successfully fulfilled' do
    ShopifyAPI::Session.expects(:temp).twice.yields
    ShopifyAPI::Order.expects(:find).returns(@order_response)
    @order_response.expects(:shipping_address).returns(mock_address)
    ShopifyAPI::Fulfillment.expects(:find).returns(@fulfillment)
    @fulfillment.expects(:complete)

    ActiveMerchant::Fulfillment::ShipwireService.expects(:new).returns(@shipwire_service)
    @shipwire_service.expects(:fulfill).returns(@response)

    CreateFulfillmentJob.perform(@example_fulfillment, @shop.domain)
    
  end

  def mock_order_response
    mock('ShopifyAPI::Order - Response') do
      stubs(:id).returns(1)
      stubs(:email).returns("test@test.com")
    end
  end

  def mock_address
    mock('Shopify Order Address') do
      stubs(:address1).returns("blag")
      stubs(:address2).returns("blag")
      stubs(:name).returns("blag")
      stubs(:company).returns("blag")
      stubs(:city).returns("blag")
      stubs(:province).returns("blag")
      stubs(:country).returns("blag")
      stubs(:zip).returns("blag")
      stubs(:phone).returns("blag")
    end
  end

  def mock_fulfillment
    mock("ShopifyAPI::Fulfillment") do

    end
  end

end