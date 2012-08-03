require 'test_helper'

class FulfillmentTest < ActiveSupport::TestCase

  should belong_to :shop
  should have_many :line_items

  def setup
    super
    stub_fulfillment_callbacks
    @order = create(:order, :shop_id => @shop.id)
  end

  test "Valid fulfillment saves" do
    fulfillment = build(:fulfillment, :line_items => [build(:line_item)])

    assert fulfillment.save
    assert fulfillment.shipwire_order_id.present?
  end

  test "Updating fulfillment does not change shipwire_order_id" do
    fulfillment = create_fulfillment

    before = fulfillment.shipwire_order_id
    fulfillment.update_attribute(:expected_delivery_date, DateTime.now)
    after = fulfillment.reload.shipwire_order_id

    assert_equal before, after
  end

  test "Fulfill line item from order" do
    Resque.expects(:enqueue)
    params = {order_ids: [@order.id], line_item_ids: [@order.line_items.first.id], shipping_method: '1D', warehouse: '00'}

    assert Fulfillment.fulfill(@shop, params)
    assert_equal "fulfilled", @order.line_items.first.fulfillment_status
  end

  test "Fulfill order" do
    Resque.expects(:enqueue)
    params = {order_ids: [@order.id], shipping_method: '1D', warehouse: '00'}

    assert Fulfillment.fulfill(@shop, params)
    assert_equal "fulfilled", @order.reload.fulfillment_status
  end

  test "Fulfill multiple orders" do
    Resque.expects(:enqueue).times(3)
    ids = [1,2,3].map{create(:order, :shop_id => @shop.id).id}
    params = {order_ids: ids, shipping_method: '1D', warehouse: '00'}

    assert_difference "Fulfillment.count", 3 do
      assert Fulfillment.fulfill(@shop, params)
    end
  end

  test "Fulfill multiple line_items from order" do
    Resque.expects(:enqueue).times(1)
    item1 = @order.line_items.first
    item2 = @order.line_items.last
    params = {order_ids: [@order.id], line_item_ids: [item1.id, item2.id], shipping_method: '1D', warehouse: '00'}


    assert Fulfillment.fulfill(@shop, params)
    assert_equal "fulfilled", item1.reload.fulfillment_status
    assert_equal "fulfilled", item2.reload.fulfillment_status
  end

  test "Fulfillment with invalid shipping_method does not save" do
    fulfillment = build(:fulfillment, :shipping_method => 'Space')

    assert !fulfillment.save, "Fulfillment with invalid shipping_method saves."
  end

  test "State machine transitions call update_fulfillment_status_with_shopify" do
    Fulfillment.any_instance.expects(:update_fulfillment_status_on_shopify).times(3)

    fulfillment = create_fulfillment
    fulfillment.success

    fulfillment.status = 'pending'
    fulfillment.cancel

    fulfillment.status = 'pending'
    fulfillment.record_failure
  end

  test "Fulfillment has appropriate fulfillment line items" do
    Resque.expects(:enqueue)
    params = {order_ids: [@order.id], shipping_method: '1D', warehouse: '00'}

    assert_difference "FulfillmentLineItem.count", 5 do
      Fulfillment.fulfill(@shop, params)
    end
  end

  test "Fulfill does not fulfill line_item if line_item status is fulfilled" do
    Resque.expects(:enqueue)
    fulfilled_item = create(:fulfilled_item)
    another_item = create(:line_item)
    order = create(:order, :line_items => [fulfilled_item, another_item], :shop => @shop)
    params = {order_ids: [order.id], line_item_ids: [fulfilled_item.id, another_item.id], shipping_method: '1D', warehouse: '00'}

    assert Fulfillment.fulfill(@shop, params)
    assert FulfillmentLineItem.where('line_item_id=?', fulfilled_item.id).empty?
  end

  test "Order is not fulfilled if not from current shop" do
    Resque.expects(:enqueue).times(1)
    order = create(:order)
    params = {order_ids: [@order.id, order.id], shipping_method: '1D', warehouse: '00'}

    Fulfillment.fulfill(@shop, params)

    assert Fulfillment.where('order_id =?', order.id).empty?
    assert Fulfillment.where('order_id=?', @order.id).present?
  end

  test "Line item is not fulfilled if id does not correspond to order" do
    Resque.expects(:enqueue)
    other_item = create(:line_item)
    params = {order_ids: [@order.id], line_item_ids: [@order.line_items.first.id, other_item.id], shipping_method: '1D', warehouse: '00'}

    assert Fulfillment.fulfill(@shop, params)
    assert_equal nil, other_item.reload.fulfillment_status
  end

  test "Fulfillment with no line_items is not saved" do
    @order.line_items.destroy_all
    params = {order_ids: [@order.id], shipping_method: '1D', warehouse: '00'}

    assert !Fulfillment.fulfill(@shop, params)
  end

  test "Fulfill returns false and does not save if the orders fulfillment status is cancelled" do
     Resque.expects(:enqueue).never
     order = create(:order, :fulfillment_status => 'cancelled', :shop_id => @shop.id)
     params = {order_ids: [order.id], shipping_method: '1D', warehouse: '00'}

     assert !Fulfillment.fulfill(@shop, params)
     assert Fulfillment.where('order_id = ?', order.id).empty?
   end

   test "Fulfill returns false and does not save if the orders fulfillment status is fulfilled" do
     Resque.expects(:enqueue).never
     order = create(:order, :fulfillment_status => 'fulfilled', :shop_id => @shop.id)
     params = {order_ids: [order.id], shipping_method: '1D', warehouse: '00'}

     assert !Fulfillment.fulfill(@shop, params)
     assert Fulfillment.where('order_id = ?', order.id).empty?
  end
end

class AnotherOtherFulfillmentTest < ActiveSupport::TestCase
  def setup
    Shop.any_instance.stubs(:setup_webhooks)

    @shop = build(:shop)
    @order = create(:order, :shop_id => @shop.id)
  end

  test "create_mirror_fulfillment_on_shopify" do
    Resque.expects(:enqueue)
    params = {order_ids: [@order.id], shipping_method: '1D', warehouse: '00'}

    ShopifyAPI::Fulfillment.expects(:create).returns(stub(:id=>20))

    assert Fulfillment.fulfill(@shop, params)
  end
end