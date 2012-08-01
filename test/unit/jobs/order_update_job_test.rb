require 'test_helper'

class OrderCancelJobTest < ActiveSupport::TestCase
  def setup
    super
  end

  test "Order updates line_item attributes on the order" do
    order = create(:order)

    item1 = {id: order.line_items.first.line_item_id, fulfillment_status: 'fulfilled'}
    item2 = {id: order.line_items.last.line_item_id, fulfillment_status: 'fulfilled'}

    OrderUpdateJob.perform([item1,item2])

    assert_equal 'fulfilled', order.reload.line_items.first.fulfillment_status
    assert_equal 'fulfilled', order.reload.line_items.last.fulfillment_status
  end
end