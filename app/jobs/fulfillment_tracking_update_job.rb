class FulfillmentTrackingUpdateJob
  @queue = :default

  def self.perform
    Shop.all.each do |shop|
      shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(shop.credentials)
      response = shipwire.fetch_shop_tracking_info(shop.orders.actives.map(&:shipwire_order_id))
      response.keys.each do |shipwire_order_id|
        order = Order.where('shipwire_order_id =?', shipwire_order_id).first
        order.tracker.update_attributes(response[shipwire_order_id])
      end
    end
  end
end