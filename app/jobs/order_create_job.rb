class OrderCreateJob
@queue = :default

  def self.perform(params, shop_id)
    puts params
    Order.create_order(params, Shop.find(shop_id))
  end
end