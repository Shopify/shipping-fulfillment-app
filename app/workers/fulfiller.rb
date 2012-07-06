class Fulfiller
  @queue = :fulfillment_que 

  def self.perform(fulfillment_id, order_id, address, line_items, options)
    fulfillment = Shopify::Fulfillment.find(fulfillment_id)
    if fulfillment.status != :pending
      return 
    else
      shipwire = ActiveMerchant::Fulfillment::ShipwireService.new({:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true}) 
      response = shipwire.fulfill(order_id, address, line_items, options)
      response.success? ? fulfillment.success : fulfillment.record_failure
    end
  end
end


#might need to check if all line_items of an order are fulfilled
