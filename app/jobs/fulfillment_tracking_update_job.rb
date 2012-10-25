class FulfillmentTrackingUpdateJob
  @queue = :default

  def self.perform
    Shop.all.each do |shop|
      shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(shop.credentials)
      active_order_ids = shop.fulfillments.where('expected_delivery_date > ?', 1.month.ago).map(&:shipwire_order_id)
      unless active_order_ids.empty?
        response = shipwire.fetch_shop_tracking_info(active_order_ids)
        response.keys.each do |shipwire_order_id|
          fulfillment = Fulfillment.find_by_shipwire_order_id(shipwire_order_id)
          fulfillment.update_attributes(response[shipwire_order_id])
        end
      end
    end
  end
end