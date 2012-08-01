class OrderCollectorJob
  @queue = :default

  def self.perform(shop)
    ShopifyAPI::Order.find_each(:batch_size => 1000, :includes => [:shipping_address, :line_items]) do |order|
      Order.create_order(self.prepare(order), shop)
    end
  end

  def self.prepare(order)
    order.shipping_address = order.shipping_address.attributes
    order.line_items.map!(&:attributes)
    order.attributes
  end

end