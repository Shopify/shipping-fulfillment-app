class OrderCollectorJob
  @queue = :default

  def self.perform
    ShopifyAPI::Order.find_each(:batch_size => 1000, :includes => [:shipping_address, :line_items]) do |order|
      shopify_order_id = order.id
      app_order = Order.new(order.attributes.merge({shopify_order_id: order.id}))
      app_order.shipping_address = ShippingAddress.create(order.shipping_address.attributes)
      app_order.line_items = order.line_items.map do |item|
        data = item.attributes
        data[:line_item_id] = data.delete(:id)
        LineItem.new(data)
      end
      app_order.save
    end
  end
end