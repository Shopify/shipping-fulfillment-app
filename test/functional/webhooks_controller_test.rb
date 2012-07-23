require 'test_helper'
require 'net/http'

FakeWeb.allow_net_connect = true

class WebhooksControllerTest < ActionController::TestCase

  def setup
    super
    @shop = create(:shop)
    @order_create = load_json('order_create.json')['order']

    WebhooksController.any_instance.stubs(:verify_shopify_webhook)
  end

  test "Order created webhook" do
    ActionDispatch::Request.any_instance.expects(:headers).returns({'HTTP_X_SHOPIFY_TOPIC' => 'orders/create'})
    #Resque.expects(:enqueue)
    post :create, @order_create

  end

  test "Order updated webhook" do
  end

  test "Order cancelled webhook" do
  end

  test "Order fulfilled webhook" do
  end

  test "Order paid webhook" do
  end

## NEED TO CHANGE SETTING TO SHOP IF USING THESE

  # test "Order paid does not fulfill if automatic_fulfillment is set to false" do
  #   order = create(:order, :shopify_order_id => 5, :setting => @setting)
  #   Fulfillment.expects(:fulfill).never()

  #   post :create, @order_create
  #   assert_response :ok
  # end

  # test "Order paid does fulfill if automatic_fulfillment is set to true" do
  #   create(:order, :shopify_order_id => 5, :setting => create(:setting_true))
  #   Fulfillment.expects(:fulfill).times(1) #TODO: expect the options passed

  #   post :create, @order_create
  #   assert_response :ok # TODO: assert the order value is updated
  # end

  # # TODO: test your slicing (pass weird data)
  # # TODO: test for hooks where you expect order to exist but it doesn't and vice versa
  # test "Order fulfilled updates the order and line_items fulfillment_status" do
  #   order = create(:order) #TODO: assert no difference
  #   post :create, {'id' => order.shopify_order_id}
  #   order.reload

  #   assert_equal order.fulfillment_status, 'fulfilled'
  #   order.line_items.each do |item|
  #     assert_equal item.fulfillment_status, 'fulfilled'
  #   end
  #   assert_response :ok
  # end

  # test "Order cancelled is updates status" do
  #   order = create(:order)

  #   post :create, {:id => order.shopify_order_id, :cancel_reason => 'customer', :cancelled_at => '2012-07-18T00:47:36-04:00'}

  #   updated_order = Order.where('shopify_order_id', order.shopify_order_id).first

  #   assert_equal updated_order.cancel_reason, "customer"
  #   assert_equal updated_order.cancelled_at, "2012-07-18T00:47:36-04:00"
  #   assert_response :ok
  # end

  # test "Order updated updates the orders line_item attributes" do
  #   order = create(:order)

  #   post :create, {:line_items => [
  #     {:id => order.line_items[0].id, :fulfillment_status => 'fulfilled'},
  #     {:id => order.line_items[1].id, :fulfillment_status => 'fulfilled'},
  #     {:id => order.line_items[2].id, :fulfillment_status => 'fulfilled'},
  #     {:id => order.line_items[3].id, :fulfillment_status => 'pending'},
  #     {:id => order.line_items[4].id, :fulfillment_status => 'pending'}]}

  #     assert_equal LineItem.where('fulfillment_status =?', 'fulfilled').count, 3
  #     assert_response :ok
  # end

  # test "Order created creates a new order" do
  #   assert_difference "Order.count", 1 do
  #     post :create, @order_create
  #   end
  #   assert_response :ok
  # end
end