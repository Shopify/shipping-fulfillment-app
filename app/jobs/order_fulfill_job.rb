class OrderFulfillJob
@queue = :default

  def self.perform(order_id)
    order = Order.find(order_id)
    order.update_attribute(:fulfillment_status, 'fulfilled')
    order.line_items.each do |item|
      item.update_attribute(:fulfillment_status, 'fulfilled')
    end
  end
end