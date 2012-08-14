require 'test_helper'
require 'net/http'

FakeWeb.allow_net_connect = true

class WebhooksControllerTest < ActionController::TestCase

  def setup
    super
    @order = create(:order, shop: @shop)
    WebhooksController.any_instance.stubs(:verify_shopify_webhook)
  end

  def webhook(topic, shop=nil)
    shop ||= @shop
    ActionController::TestRequest.any_instance.stubs(:headers).returns({'HTTP_X_SHOPIFY_TOPIC' => topic, 'HTTP_X_SHOPIFY_SHOP_DOMAIN' => shop.domain})
  end

  def expect(*args)
    Resque.expects(:enqueue).with(*args)
  end

  def ping(params =nil)
    params ||= {}
    # post :order, {id: @order.shopify_order_id}.merge(params)
  end

  test "Order created webhook" do
    webhook('orders/create')
    expect(OrderCreateJob, {'id' => @order.shopify_order_id.to_s}, @shop.id)
    ping
  end

  test "Order updated webhook" do
    webhook('orders/updated')
    expect(OrderUpdateJob,['test'])
    ping({line_items: ['test']})
  end

  test "Order cancelled webhook" do
    webhook('orders/cancelled')
    expect(OrderCancelJob, @order.id, 'cancelled_at', 'cancel_reason')
    ping({cancelled_at: 'cancelled_at', cancel_reason: 'cancel_reason'})
  end

  test "Order fulfilled webhook" do
    webhook('orders/fulfilled')
    expect(OrderFulfillJob, @order.id)
    ping
  end

  test "Order paid webhook without automatic fulfillment" do
    webhook('orders/paid')
    Order.any_instance.expects(:update_attribute).with(:financial_status, 'paid')
    ping({shipping_lines: 'shipping_lines'})
  end

  test "Order paid webhook with automatic fulfillment" do
    @shop.update_attribute(:automatic_fulfillment, true)
    webhook('orders/paid')
    Order.any_instance.expects(:update_attribute).with(:financial_status, 'paid')
    expect(OrderPaidJob, @order.id, @shop.id, 'shipping_lines')
    ping({shipping_lines: 'shipping_lines'})
  endf

  test "Fulfillment created webhook" do
    webhook('fulfillments/create')
    #TODO FInISH TEST
  end

  test "fulfillment updated webhook" do
    #TODO
  end
end