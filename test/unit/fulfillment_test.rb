require 'test_helper'

class FulfillmentTest < ActiveSupport::TestCase

  should belong_to :setting
  should have_many :line_items
  should have_one :tracker
  should have_db_index :setting_id
  should validate_presence_of :order_id
  should validate_presence_of :line_items

  def setup
    Setting.any_instance.stubs(:setup_webhooks)

    Fulfillment.any_instance.stubs(:create_mirror_fulfillment_on_shopify)

    @setting = build(:setting)
    @order = create(:order, :setting_id => @setting.id)
  end

  test "Valid fulfillment saves and creates associated tracker" do
    fulfillment = build(:fulfillment, :line_items => [build(:line_item)])

    assert fulfillment.save
    assert fulfillment.reload.tracker.present?
  end

  test "Fulfill line item from order" do
    Resque.expects(:enqueue)
    params = {order_ids: [@order.id], line_item_ids: [@order.line_items.first.id], shipping_method: '1D', warehouse: '00'}

    assert Fulfillment.fulfill(@setting, params)
    assert_equal @order.line_items.first.fulfillment_status, "fulfilled"
  end

  test "Fulfill order" do
    Resque.expects(:enqueue)
    params = {order_ids: [@order.id], shipping_method: '1D', warehouse: '00'}

    assert Fulfillment.fulfill(@setting, params)
    assert_equal @order.reload.fulfillment_status, "fulfilled"
  end

  test "Fulfill multiple orders" do
    Resque.expects(:enqueue).times(3)
    ids = [1,2,3].map{create(:order, :setting_id => @setting.id).id}
    params = {order_ids: ids, shipping_method: '1D', warehouse: '00'}

    assert_difference "Fulfillment.count", 3 do
      assert Fulfillment.fulfill(@setting, params)
    end
  end

  test "Fulfill multiple line_items from order" do
    Resque.expects(:enqueue).times(1)
    item1 = @order.line_items.first
    item2 = @order.line_items.last
    params = {order_ids: [@order.id], line_item_ids: [item1.id, item2.id], shipping_method: '1D', warehouse: '00'}


    assert Fulfillment.fulfill(@setting, params)
    assert_equal item1.reload.fulfillment_status, "fulfilled"
    assert_equal item2.reload.fulfillment_status, "fulfilled"
  end

  test "Fulfillment with invalid shipping_method does not save" do
    fulfillment = build(:fulfillment, :shipping_method => 'Space')

    assert !fulfillment.save, "Fulfillment with invalid shipping_method saves."
  end

  test "State machine transitions call update_fulfillment_status_with_shopify" do
    Fulfillment.any_instance.expects(:update_fulfillment_status_on_shopify).times(3)

    fulfillment = create(:fulfillment, :line_items => [build(:line_item)])
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
      Fulfillment.fulfill(@setting, params)
    end
  end

  test "Fulfill does not fulfill line_item if line_item status is fulfilled or cancelled" do
    Resque.expects(:enqueue)
    cancelled_item = create(:cancelled_item)
    fulfilled_item = create(:fulfilled_item)
    order = create(:order, :line_items => [cancelled_item, fulfilled_item], :setting => @setting)
    params = {order_ids: [order.id], shipping_method: '1D', warehouse: '00'}

    assert Fulfillment.fulfill(@setting, params)
    assert FulfillmentLineItem.where('line_item_id =?', cancelled_item.id).empty?
    assert FulfillmentLineItem.where('line_item_id=?', fulfilled_item.id).empty?
  end

  test "Order is not fulfilled if not from current setting" do
    Resque.expects(:enqueue).times(1)
    order = create(:order)
    params = {order_ids: [@order.id, order.id], shipping_method: '1D', warehouse: '00'}

    Fulfillment.fulfill(@setting, params)

    assert Fulfillment.where('order_id =?', order.id).empty?
    assert Fulfillment.where('order_id=?', @order.id).present?
  end

  test "Line item is not fulfilled if id does not correspond to order" do
    Resque.expects(:enqueue)
    other_item = create(:line_item)
    params = {order_ids: [@order.id], line_item_ids: [@order.line_items.first.id, other_item.id], shipping_method: '1D', warehouse: '00'}

    assert Fulfillment.fulfill(@setting, params)
    assert_equal other_item.reload.fulfillment_status, nil
  end

  test "Fulfillment with no line_items is not saved" do
    @order.line_items.destroy_all
    params = {order_ids: [@order.id], shipping_method: '1D', warehouse: '00'}

    assert !Fulfillment.fulfill(@setting, params)
  end

  test "Fulfill returns false and does not save if the orders fulfillment status is cancelled" do
     Resque.expects(:enqueue).never
     order = create(:order, :fulfillment_status => 'cancelled', :setting_id => @setting.id)
     params = {order_ids: [order.id], shipping_method: '1D', warehouse: '00'}

     assert !Fulfillment.fulfill(@setting, params)
     assert Fulfillment.where('order_id = ?', order.id).empty?
   end

   test "Fulfill returns false and does not save if the orders fulfillment status is fulfilled" do
     Resque.expects(:enqueue).never
     order = create(:order, :fulfillment_status => 'fulfilled', :setting_id => @setting.id)
     params = {order_ids: [order.id], shipping_method: '1D', warehouse: '00'}

     assert !Fulfillment.fulfill(@setting, params)
     assert Fulfillment.where('order_id = ?', order.id).empty?
  end
end

class AnotherOtherFulfillmentTest < ActiveSupport::TestCase
  def setup
    Setting.any_instance.stubs(:setup_webhooks)

    @setting = build(:setting)
    @order = create(:order, :setting_id => @setting.id)
  end

  test "create_mirror_fulfillment_on_shopify" do
    Resque.expects(:enqueue)
    params = {order_ids: [@order.id], shipping_method: '1D', warehouse: '00'}

    ShopifyAPI::Fulfillment.expects(:create).returns(stub(:id=>20))

    assert Fulfillment.fulfill(@setting, params)
  end
end