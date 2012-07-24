class OrderPaidJob
@queue = :default

  def self.perform(order, shipping_params)
    shipping_method = shipping_params.first['code']

    options = {
      order_id: order.id,
      shipping_method: shipping_method
    }

    Fulfillment.fulfill(order.shop, options)
  end
end