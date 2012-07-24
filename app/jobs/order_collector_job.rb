class OrderCollectorJob
  @queue = :default

  def self.perform(shop)
    ShopifyAPI::Order.find_each(:batch_size => 1000, :includes => [:shipping_address, :line_items]) { |order| self.create_order(shop, order) }
  end

  def self.create_order(shop, shopify_order)
      order = shop.orders.new(shopify_order.attributes.merge({shopify_order_id: shopify_order.id}).slice(*Order.column_names))
      order.shipping_address = ShippingAddress.create(shopify_order.shipping_address.attributes.slice(*ShippingAddress.column_names))
      order.line_items = shopify_order.line_items.map { |item| self.build_line_item(item) }
      order.save
  end

  def self.build_line_item(item)
    data = item.attributes
    data['line_item_id'] = data.delete('id')
    data.slice(*LineItem.column_names)
    LineItem.new(data)
  end
end