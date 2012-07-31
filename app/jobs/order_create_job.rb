class OrderCreateJob
@queue = :default

  def self.perform(params, shop_id)
    Order.create_order(params, Shop.find(shop_id))
  end
end