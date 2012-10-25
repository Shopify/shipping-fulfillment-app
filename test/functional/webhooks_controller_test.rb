require 'test_helper'
require 'net/http'

FakeWeb.allow_net_connect = true

class WebhooksControllerTest < ActionController::TestCase

  def setup
    WebhooksController.any_instance.stubs(:verify_shopify_webhook)
    @shop = shops(:david)
  end

  test "App uninstalled webhook" do
    webhook('app/uninstalled')
    Resque.expects(:enqueue).with(AppUninstalledJob, @shop.domain)
    post :uninstalled
  end

  test "Fulfillment created webhook" do
    webhook('fulfillments/create')
    Resque.expects(:enqueue).with(CreateFulfillmentJob, anything, @shop.domain)
    post :fulfillment, {:id => 123, :service => 'shipwire-app'}
  end

  test "fulfillment updated webhook" do
    #TODO
  end

  private

  def webhook(topic)
    ActionController::TestRequest.any_instance.stubs(:headers).returns({'HTTP_X_SHOPIFY_TOPIC' => topic, 'HTTP_X_SHOPIFY_SHOP_DOMAIN' => @shop.domain})
  end
end