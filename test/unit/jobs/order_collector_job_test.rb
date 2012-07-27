require 'test_helper'

class OrderCollectorJobTest < ActiveSupport::TestCase
  def setup
    super
  end

  test "Perform makes api call" do
    ShopifyAPI::Order.expects(:find_each)
    OrderCollectorJob.perform(@shop)
  end

  test "Build_line_item builds line item" do
    item = load_json('item.json')
    line_item = OrderCollectorJob.build_line_item(item)
    assert line_item.valid?
  end

  test "Create_order creates a new order" do
    order = load_json('order1.json')
    OrderCollectorJob.create_order(@shop, order)
  end
end

class Hash
  def attributes
    return self
  end

  def id
    return self['id']
  end

  def shipping_address
    return self['shipping_address']
  end

  def line_items
    return self['line_items']
  end
end
