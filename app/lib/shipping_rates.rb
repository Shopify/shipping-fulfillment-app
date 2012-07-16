class ShippingRates

  LOGIN_CREDENTIALS = {:login => 'pixels@jadedpixel.com', :password => 'Ultimate', :test => true}

  def self.find_order_rates(order_id)
    items, destination = ShippingRates.destination_and_items(order_id)
      rates = Rails.cache.fetch(self.rates_cache_key(destination, order_id), :expires_in => 1.day) do
        # TODO: credentials
        shipwire = ActiveMerchant::Shipping::Shipwire.new(LOGIN_CREDENTIALS)
        begin
          response = shipwire.find_rates(nil, destination, nil, :items => items)
        rescue ActiveMerchant::Shipping::ResponseError
          return nil
        else
          estimates = response.estimates
          estimates.collect { |estimate| self.rate_from_estimate(estimate) }
        end
      end
    rates.to_json
  end

  private 

  def self.destination_and_items(order_id)
    order = ShopifyAPI::Order.find(order_id)
    address = order.shipping_address

    location = {
      country: address.country,
      province: address.province,
      city: address.city,
      name: address.name,
      address1: address.address1,
      address2: nil,
      address3: nil,
      phone: address.phone,
      fax: nil,
      company: address.company
    }

    items = order.line_items.select{ |item| item.requires_shipping && item.fulfillment_service == "shipwire"}
    items = items.map(&:attributes)
    return items, ActiveMerchant::Shipping::Location.new(location)
  end

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