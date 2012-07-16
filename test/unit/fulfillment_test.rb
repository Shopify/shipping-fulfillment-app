require 'test_helper'

class FulfillmentTest < ActiveSupport::TestCase

  should belong_to :setting
  should have_many :line_items
  should have_one :tracker
  should have_db_index :setting_id
  should validate_presence_of :shopify_order_id

  def setup
    session = ShopifyAPI::Session.new("http://localhost", "123")
    ShopifyAPI::Base.activate_session(session)

    Fulfillment.any_instance.stubs(:create_mirror_fulfillment_on_shopify)
    Setting.any_instance.stubs(:setup_webhooks)
  end

  test "Valid fulfillment saves along with its associations" do
    fulfillment = FactoryGirl.build(:fulfillment) # TODO: helper method to setup objects
    fulfillment.tracker = FactoryGirl.build(:tracker)
    fulfillment.line_items = [FactoryGirl.build(:line_item)]
    
    assert fulfillment.save, "Valid fulfillment saves."
    assert Tracker.find_by_id(fulfillment.tracker.id).present?, "Associated tracker did not save."
    assert LineItem.find_by_id(fulfillment.line_items.first.id).present?, "Associated line_items did not save."
  end

  test "Fulfillment with invalid tracker does not save" do
    fulfillment = FactoryGirl.build(:fulfillment)
    fulfillment.tracker = FactoryGirl.build(:tracker, :shipwire_order_id => nil)
    fulfillment.line_items = [FactoryGirl.build(:line_item)]

    assert !fulfillment.save, "Fulfillment saved with invalid tracker."
  end

  test "Fulfillment with invalid line_items does not save" do
    fulfillment = FactoryGirl.build(:fulfillment)
    fulfillment.tracker = FactoryGirl.build(:tracker)
    fulfillment.line_items = [FactoryGirl.build(:line_item, :variant_id => nil)]

    assert !fulfillment.save, "Fulfillment saved with invalid line_item."
  end

  test "Fulfill line item from order" do
    Resque.expects(:enqueue)
    fake "admin/orders/18", :body => load_fixture('order18'), :method => :get,  :format => 'json'
    params = {shopify_order_id: 18, line_item_ids: [30], shipping_method: '1D', warehouse: '00'}
    setting = FactoryGirl.build(:setting)
    
    assert Fulfillment.fulfill_line_items?(setting, params)
  end

  test "Fulfill order" do
    Resque.expects(:enqueue)
    fake "admin/orders/18", :body => load_fixture('order18'), :method => :get,  :format => 'json'
    params = {shopify_order_ids: [18], shipping_method: '1D', warehouse: '00'}
    setting = FactoryGirl.build(:setting)
    
    assert Fulfillment.fulfill_orders?(setting, params)
  end

  test "Fulfillment calls calls either fulfill_orders? or fulfill_line_items?" do
    setting = FactoryGirl.build(:setting)
    Fulfillment.expects(:fulfill_orders?)
    Fulfillment.fulfill(setting, {shopify_order_ids: [1,2,3]})

    Fulfillment.expects(:fulfill_line_items?)
    Fulfillment.fulfill(setting, {shopify_order_id: 1})
  end

  test "Fulfillment with invalid shipping_method does not save" do
    fulfillment = FactoryGirl.build(:fulfillment, :shipping_method => 'Space')

    assert !fulfillment.save, "Fulfillment with invalid shipping_method saves."
  end

  test "state machine transitions call update_fulfillment_status_with_shopify" do
    Fulfillment.any_instance.expects(:update_fulfillment_status_with_shopify).times(3)
    
    fulfillment = FactoryGirl.build(:fulfillment)
    fulfillment.success
    
    fulfillment.status = 'pending'
    fulfillment.cancel
    
    fulfillment.status = 'pending'
    fulfillment.record_failure
  end

  test "Make shipwire order_id" do
    shipwire_order_id = Fulfillment.make_shipwire_order_id(18)
    assert_equal '18.', shipwire_order_id[0..2]
  end
end

class AnotherFulfillmentTest < ActiveSupport::TestCase
  def setup 
    session = ShopifyAPI::Session.new("http://localhost", "123")
    ShopifyAPI::Base.activate_session(session)
  end

  test "create_mirror_fulfillment_on_shopify" do
    fulfillment = FactoryGirl.build(:fulfillment, line_items: [FactoryGirl.build(:line_item), FactoryGirl.build(:line_item)])

    ShopifyAPI::Fulfillment.expects(:new).with(
      order_id: 19232494,
      test: false,
      shipping_method: '1D',
      line_items: [1,2]
      ).returns(fulfillment)

    fulfillment.create_mirror_fulfillment_on_shopify
  end
end