class ShippingRates

  # IMPERIAL_DIMENSIONS = [5.1, 15.2, 30.5].freeze
  # METRIC_DIMENSIONS = [5.0, 15.0, 30.0].freeze
  # MAXIMUM_WEIGHT_IN_GRAMS = 68038.freeze


  def find_rates(destination, order_id)
    order = ShopifyAPI::Order.find(order_id)
    items = order.line_items.select{ |item| item.requires_shipping && item.fulfillment_service == "shipwire"}
    total_weight = items.inject{ |sum, item| sum + item.grams * item.quantity}

    ## item only needs sku and quantity
    ## This one is in metric 
    rates = Rails.cache.fetch(rates_cache_key(destination, order_id), :expires_in => 1.day) do
      #packages are not used
      #packages = ActiveMerchant::Shipping::ShipmentPacker.pack(items, METRIC_DIMENSIONS, MAXIMUM_WEIGHT_IN_GRAMS, 'USD')
      shipwire = ActiveMerchant::Shipping::Shipwire.new({:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true})
      response = shipwire.find_rates(nil, destination, nil, :items => items)
      estimates = response.estimates
      puts "Estimates: #{response.estimates.inspect}"
      estimates.collect { |estimate| rate_from_estimate(estimate) }
    end
    rates.to_json
  end


  #handle response
  private 

  def rate_from_estimate(estimate)
    price = (estimate.total_price.to_f / 100).round(2).to_s
    {
      service: estimate.service_name,
      service_code: estimate.service_code,
      price: price,
      estimated_delivery_date: estimate.delivery_date,
      estimated_delivery_range: estimate.delivery_range
    }
  end

  def rates_cache_key(destination, order_id)
    "#{order_id} - #{destination.address1}"
  end

end



## Destination will be different for each order
'Full', destination.name
'Address1', destination.address1
'Company', destination.company unless destination.company.blank?
'City', destination.city
'State', destination.state unless destination.state.blank?
'Country', destination.country_code
'Zip', destination.zip  unless destination.zip.blank?
 