require 'test_helper'

class OrderCollectorJobTest < ActiveSupport::TestCase
  def setup
    super
  end

  test "Perform makes api call" do
    ShopifyAPI::Order.expects(:find_each)
    OrderCollectorJob.perform(@shop)
  end

  test "Create_order creates a new order" do
    order = load_json('order1.json').with_indifferent_access
    assert_difference "Order.count", 1 do
      Order.create_order(order,@shop)
    end
  end
end