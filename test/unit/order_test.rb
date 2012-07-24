require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  should belong_to :shop
  should have_many :line_items
  should have_one :shipping_address

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

    order = create(:order, :line_items => [manual_service_item, fulfilled_item, good_item])

    assert_equal order.filter_fulfillable_items(order.line_items.map(&:id).push(create(:line_item))), [good_item]
  end

end
