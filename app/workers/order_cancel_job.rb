class OrderCancelJob
@queue = :default

  def self.perform(order, cancelled_at, cancel_reason)
    order.update_attribute('cancelled_at', cancelled_at)
    order.update_attribute('cancel_reason', cancel_reason)
  end
end