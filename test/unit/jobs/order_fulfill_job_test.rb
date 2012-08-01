require 'test_helper'

class OrderFulfillTest < ActiveSupport::TestCase
  def setup
    super
    @order = create(:order)
  end

  test "Perform updates the order and corresponding line item fulfillment statuses" do
    OrderFulfillJob.perform(@order)

    assert_equal 'fulfilled', @order.reload.fulfillment_status
    @order.line_items.each {|item| assert_equal 'fulfilled', item.fulfillment_status}
  end
end