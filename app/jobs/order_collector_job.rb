class OrderCollectorJob
  @queue = :default

  def self.perform(shop)
    ShopifyAPI::Session.temp(shop.base_url, shop.token) {
      ShopifyAPI::Order.find(:all, :params => {:limit => 250}).each do |order|
        Order.create_order(self.prepare(order), shop)
      end
    }
  end

  def self.prepare(order)
    order.shipping_address = order.shipping_address.attributes
    order.line_items.map!(&:attributes)
    order.attributes
  end

end