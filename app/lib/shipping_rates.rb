class ShippingRates

  def self.find_rates(destination, order_id)
    order = ShopifyAPI::Order.find(order_id)
    items = order.line_items.select{ |item| item.requires_shipping && item.fulfillment_service == "shipwire"}
    items = items.map(&:attributes)
    #total_weight = items.inject{ |sum, item| sum + item.grams * item.quantity}
    puts "Items: #{items.inspect}"
    ## item only needs sku and quantity
    rates = Rails.cache.fetch(self.rates_cache_key(destination, order_id), :expires_in => 1.day) do
      shipwire = ActiveMerchant::Shipping::Shipwire.new({:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true})
      puts "midway"
      response = shipwire.find_rates(nil, destination, nil, :items => items)
      estimates = response.estimates
      puts "Estimates: #{response.estimates.inspect}"
      estimates.collect { |estimate| self.rate_from_estimate(estimate) }
    end
    rates.to_json
  end

  private 

  def self.rate_from_estimate(estimate)
    price = (estimate.total_price.to_f / 100).round(2).to_s
    {
      service: estimate.service_name,
      service_code: estimate.service_code,
      price: price,
      estimated_delivery_date: estimate.delivery_date,
      estimated_delivery_range: estimate.delivery_range
    }
  end

  def self.rates_cache_key(destination, order_id)
    "#{order_id} - #{destination.address1}"
  end

end