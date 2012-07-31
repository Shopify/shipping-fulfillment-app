class OrderCancelJob
@queue = :default

  def self.perform(order_id, cancelled_at, cancel_reason)
    order = Order.find(order_id)
    order.update_attributes(cancelled_at: cancelled_at, cancel_reason: cancel_reason)
  end
end