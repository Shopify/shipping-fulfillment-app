class Fulfiller
  @queue = :fulfillment_que 

  def self.perform(fulfillment_id, shipwire_order_id, shipping_address, line_items, options)
    fulfillment = Fulfillment.find_by_id(fulfillment_id)
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new({:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true}) 
    response = shipwire.fulfill(shipwire_order_id, shipping_address, line_items, options)
    response.success? ? fulfillment.success : fulfillment.record_failure
  end
end