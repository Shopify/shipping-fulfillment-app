require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  should belong_to :shop
  should have_many :line_items
  should have_one :shipping_address

  def setup
    super
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
    assert ShippingAddress.where("address1 = ?","7318 Black Swan Place").present?
  end

  test "Filter fulfillable line items" do
    fulfilled = create(:fulfilled_item)
    manual = create(:manual_service_item)
    good = create(:line_item)
    other = create(:line_item)
    order = create(:order, :line_items => [manual, fulfilled, good])

    mixed = order.line_items.map(&:id).push(other.id)
    fulfillable = order.filter_fulfillable_items(mixed)

    assert_equal fulfillable, [good]
  end

end
