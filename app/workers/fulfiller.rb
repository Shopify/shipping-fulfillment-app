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


#<ActiveMerchant::Fulfillment::Response:0x007f90b459eba0 @params={"status"=>"0", "total_orders"=>"1", "total_items"=>"0", "transaction_id"=>"1340715733-966655-1", "order_information"=>"\n    ", "processing_time"=>"471", "success"=>true, "message"=>"Successfully submitted the order"}, @message="Successfully submitted the order", @success=true, @test=true>
