class ShippingRates

  def self.find_order_rates(shop, order_id)
    order = shop.orders.find(order_id)
    destination = self.destination(order.shipping_address)
    items = order.line_items.select { |item| item.requires_shipping && item.fulfillment_service == "shipwire" }
    items_attributes = items.map(&:attributes)
    rates = self.rate_request(shop, order_id, destination, items_attributes)
  end

## rates = [{:service=>"UPS Second Day Air", :service_code=>"1D", :price=>"17.44", :estimated_delivery_date=>Wed, 01 Aug 2012 00:00:00 +0000, :estimated_delivery_range=>[Thu, 26 Jul 2012 00:00:00 +0000, Wed, 01 Aug 2012 00:00:00 +0000]}]

  private

  def self.rate_request(shop, order_id, destination, items_attributes)
    Rails.cache.fetch(self.rates_cache_key(order_id), expires_in: 1.day) do
      shipwire = ActiveMerchant::Shipping::Shipwire.new(shop.credentials)
      begin
        response = shipwire.find_rates(nil, destination, nil, items: items_attributes)
      rescue ActiveMerchant::Shipping::ResponseError
        return nil
      else
        estimates = response.estimates
        estimates.collect { |estimate| self.rate_from_estimate(estimate) }
      end
    end
  end

  def self.destination(address)

    location = {
      country: address.country,
      province: address.province,
      city: address.city,
      name: nil,
      address1: address.address1,
      address2: nil,
      address3: nil,
      phone: nil,
      fax: nil,
      company: nil
    }

    ActiveMerchant::Shipping::Location.new(location)
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

  def self.rates_cache_key(order_id)
    "#{order_id}"
  end

end