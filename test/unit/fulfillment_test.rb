require 'test_helper'

class FulfillmentTest < ActiveSupport::TestCase

  def setup
    fake "admin/orders/18", :body => load_fixture('order18'), :method => :get,  :format => 'json'
    Resque.stubs(:enqueue)
  end

  test "fulfill order with multiple line items" do
    assert Fulfillment.fulfill("myshop1",[18],"1D","123456789")
  end

  test "fulfill individual line item" do
    assert Fulfillment.fulfill("myshop1",[18],"1D","123456789",[30])
  end

  test "invalid shipping method does not validate" do
    assert_equal false, Fulfillment.fulfill("myshop1",[18],"Invalid Shipping","123456789",[30])
  end

  should validate_presence_of(:line_items)
  should validate_presence_of(:address)
  should validate_presence_of(:order_id)

  should have_db_index(:setting_id)
  
  should belong_to(:setting)
end