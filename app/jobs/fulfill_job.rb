class FulfillJob
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
    if response.success?
      fulfillment.success
      %w(origin_lat origin_long destination_lat destination_long).each do |key|
        fulfillment.update_attribute(key, BigDecimal.new(response.params[key])) if response.params.has_key?(key)
      end
    else
      fulfillment.record_failure
    end
  end
end
