require 'test_helper'

class OrderFulfillTest < ActiveSupport::TestCase
  def setup
    super
    @order = create(:order)
  end

  test "Perform updates the order and corresponding line item fulfillment statuses" do
    OrderFulfillJob.perform(@order)

    assert_equal @order.reload.fulfillment_status, 'fulfilled'
    @order.line_items.each {|item| assert_equal item.fulfillment_status, 'fulfilled'}
  end
end