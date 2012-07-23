class OrderPaidJob
@queue = :default

  def self.perform(order, shopify_order_id, shipping_method_params)
    options = {
      shopify_order_id: shopify_order_id,
      shipping_method: self.shipping_method_from(shipping_method_params)
    }
    Fulfillment.fulfill(order.setting, options)
  end

  def self.shipping_method_from(params)
    shipping_line = params['shipping_lines'].first
    return shipping_line['code']
  end
end