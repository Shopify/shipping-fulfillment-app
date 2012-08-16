require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  def setup
    super
  end

  test "Valid order saves" do
    assert create_order
  end

  test "Create order makes order with line_items" do
    params = load_json('order_create.json')['order'].with_indifferent_access

    assert_difference "Order.count", 1 do
      Order.create_order(params, @shop)
    end
    assert LineItem.where("sku = ?","909090").present?
  end

  test "Filter fulfillable line items" do
    fulfilled = create(:fulfilled_item, shop: @shop)
    manual = create(:manual_service_item, shop: @shop)
    good = create(:line_item, shop: @shop)
    other = create(:line_item, shop: @shop)
    order = create(:order, :line_items => [manual, fulfilled, good])

    mixed = order.line_items.map(&:id).push(other.id)
    fulfillable = order.filter_fulfillable_items(mixed)

    assert_equal [good], fulfillable
  end

  test "#address should return hash of all the orders address attributes" do
    order = create_order
    expected_address = {
      address1: '532 Beacon Street',
      address2: '7318 Black Swan Place',
      city: 'Carlsbad',
      zip: '92011',
      province: 'CA',
      country: 'United States',
      latitude: BigDecimal.new('43.999'),
      longitude: BigDecimal.new('43.999')
    }

    assert_equal expected_address, order.address
  end
end