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
    Fulfillment.any_instance.stubs(:order_fulfillment_status).returns(true)
  end

  test "Valid fulfillment saves and creates associated tracker" do
    fulfillment = FactoryGirl.build(:fulfillment)
    fulfillment.line_items = [FactoryGirl.build(:line_item)]

    assert fulfillment.save
    assert Tracker.find(fulfillment.tracker.id).present?, "Tracker did not save with corresponding fulfillment."
  end

  test "Fulfillment with invalid line_items does not save" do
    fulfillment = FactoryGirl.build(:fulfillment)
    fulfillment.line_items = [FactoryGirl.build(:line_item, :variant_id => nil)]

    assert !fulfillment.save, "Fulfillment saved with invalid line_item."
  end

  test "Fulfill line item from order" do
    Resque.expects(:enqueue)
    fake "admin/orders/18", :body => load_fixture('order18'), :method => :get,  :format => 'json'
    params = {shopify_order_ids: [18], line_item_ids: [30], shipping_method: '1D', warehouse: '00'}
    setting = FactoryGirl.build(:setting)

    assert Fulfillment.fulfill(setting, params)
  end

  test "Fulfill order" do
    Resque.expects(:enqueue)
    fake "admin/orders/18", :body => load_fixture('order18'), :method => :get,  :format => 'json'
    params = {shopify_order_ids: [18], shipping_method: '1D', warehouse: '00'}
    setting = FactoryGirl.build(:setting)

    assert Fulfillment.fulfill(setting, params)
  end

  test "Fulfill multiple orders" do
    Resque.expects(:enqueue).times(3)
    fake "admin/orders/18", :body => load_fixture('order18'), :method => :get,  :format => 'json'
    fake "admin/orders/35", :body => load_fixture('order35'), :method => :get,  :format => 'json'
    fake "admin/orders/22", :body => load_fixture('order22'), :method => :get,  :format => 'json'
    params = {shopify_order_ids: [18,35,22], shipping_method: '1D', warehouse: '00'}
    setting = FactoryGirl.build(:setting)

    assert Fulfillment.fulfill(setting, params)
  end

  test "Fulfill multiple line_items from order" do
    Resque.expects(:enqueue).times(1)
    fake "admin/orders/35", :body => load_fixture('order35'), :method => :get,  :format => 'json'
    params = {shopify_order_ids: [35], shipping_method: '1D', warehouse: '00', line_item_ids: [55,56]}
    setting = FactoryGirl.build(:setting)

    assert Fulfillment.fulfill(setting, params)
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

  test "Fulfill returns false if the orders fulfillment status is fulfilled or cancelled" do
    # Resque.expects(:enqueue).never
    # fake "admin/orders/5", :body => load_fixture('order5'), :method => :get,  :format => 'json'
    # params = {shopify_order_ids: [5], shipping_method: '1D', warehouse: '00'}
    # setting = FactoryGirl.build(:setting)

    # assert !Fulfillment.fulfill(setting, params)
    true
  end

  test "Fulfill does not save and returns false if line_item status is fulfilled or cancelled" do
    assert true
  end

  test "Fulfill does not save and returns false if order is not from current setting" do
    assert true
  end

  test "fulfillment is not created if any line item id does not correspond to order" do
    assert true
  end

end

class AnotherFulfillmentTest < ActiveSupport::TestCase
  def setup
    session = ShopifyAPI::Session.new("http://localhost", "123")
    ShopifyAPI::Base.activate_session(session)
  end

  test "create_mirror_fulfillment_on_shopify" do
    # fulfillment = FactoryGirl.build(:fulfillment, line_items: [FactoryGirl.build(:line_item), FactoryGirl.build(:line_item)])

    # ShopifyAPI::Fulfillment.expects(:new).with(
    #   order_id: 19232494,
    #   test: false,
    #   shipping_method: '1D',
    #   line_items: [1,2]
    #   ).returns(fulfillment)

    # fulfillment.create_mirror_fulfillment_on_shopify
    assert true
  end
end