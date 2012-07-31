class ShippingRates

  def initialize(shop, shopify_order_id)
    @order = shop.orders.find_by_shopify_order_id(shopify_order_id)
    @shipment_destination = destination
  end

  def find_order_rates
    items = @order.line_items.select { |item| item.requires_shipping && item.fulfillment_service == "shipwire" }
    items_attributes = items.map(&:attributes)
    rates = rate_request(items_attributes)
  end

  private

  def rate_request(items_attributes)
    Rails.cache.fetch(rates_cache_key, expires_in: 1.day) do
      shipwire = ActiveMerchant::Shipping::Shipwire.new(@order.shop.credentials)
      response = shipwire.find_rates(nil, @shipment_destination, nil, items: items_attributes)
      response.estimates.collect { |estimate| rate_from_estimate(estimate) }
    end
  rescue ActiveMerchant::Shipping::ResponseError
    nil
  end

  def destination
    address = @order.shipping_address

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

  def rates_cache_key
    "ShippingRates:#{@order.id}"
  end

end