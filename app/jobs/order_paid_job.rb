class OrderPaidJob
@queue = :default

  def self.perform(order_id, shop_id, shipping_params)
    method = shipping_params.first['code']

    Fulfillment.fulfill(Shop.find(shop_id), {order_ids: [order_id], shipping_method: method})
  end
end