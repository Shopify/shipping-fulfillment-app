class FulfillmentTrackingUpdateJob
  @queue = :default

  def self.perform
    Shop.all.each do |shop|
      shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(shop.credentials)
      Shop.orders.where('expected_delivery_date > ?', Datetime.now).each do |order|
        response = shipwire.fetch_tracking_updates(order.tracker.shipwire_order_id)
        order.tracker.update_attributes(response[shipwire_order_id])
      end
    end
  end
end