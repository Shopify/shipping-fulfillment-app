class FulfillmentsTracker
  @queue = :fulfillment_que

  LOGIN_CREDENTIALS = {:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true}

  def self.perform
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(LOGIN_CREDENTIALS) 
    response = shipwire.fetch_tracking_updates
    response.keys.each do |shipwire_order_id|
      tracker = Tracker.where('shipwire_order_id = ?', shipwire_order_id)
      tracker.update_attributes(response[shipwire_order_id])
    end
  end
end