require 'test_helper'

class OrderCancelJobTest < ActiveSupport::TestCase
  test "Order cancelled updates attributes on the order" do
    order = create(:order)
    time = DateTime.parse('2011-04-15 00:00:00')
    reason = 'customer'

    OrderCancelJob.perform(order, time, reason)

    assert_equal time, order.reload.cancelled_at
    assert_equal reason, order.reload.cancel_reason
  end
end