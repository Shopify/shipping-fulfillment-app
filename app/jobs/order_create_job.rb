class OrderCreateJob
@queue = :default

  def self.perform(params, setting)
    Order.create_order(params, setting)
  end
end