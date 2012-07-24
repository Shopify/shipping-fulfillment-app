class OrderCreateJob
@queue = :default

  def self.perform(params, shop)
    Order.create_order(params, shop)
  end
end