require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  should belong_to :shop
  should have_many :line_items
  should have_one :shipping_address

  def setup
    Shop.any_instance.stubs(:setup_webhooks)
    Shop.any_instance.stubs(:set_domain)
  end

  test "Valid order saves" do
    assert create(:order), "Valid order did not save."
  end

  test "Create order makes order with apropriate attributes" do
    params = load_json('order_create.json')['order']
    assert_difference "Order.count", 1 do
      Order.create_order(params, create(:shop))
    end
    assert LineItem.where("sku = ?","909090").present?
    assert ShippingAddress.where("address1 = ?","7318 Black Swan Place").present?, "Did"
  end

  test "Filter fulfillable line items" do
    fulfilled_item = create(:fulfilled_item)
    manual_service_item = create(:manual_service_item)
    good_item = create(:line_item)
    other_orders_item = create(:line_item)

    order = create(:order, :line_items => [manual_service_item, fulfilled_item, good_item])
    mixed_items = order.line_items.map(&:id).push(other_orders_item)
    good_items = order.filter_fulfillable_items(mixed_items)

    assert_equal good_items, [good_item]
  end

end
