class FulfillmentJob
  @queue = :default

  def self.perform(fulfillment_id)
    fulfillment = Fulfillment.includes(:line_items, :shop).find(fulfillment_id)
    line_items = fulfillment.line_items.map(&:attributes)
    options = {
      warehouse: fulfillment.warehouse,
      email: fulfillment.email,
      shipping_method: fulfillment.shipping_method
    }
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(fulfillment.shop.credentials)
    response = shipwire.fulfill(fulfillment.shipwire_order_id, fulfillment.order.shipping_address, line_items, options)
    response.success? ? fulfillment.success : fulfillment.record_failure
  end
end
