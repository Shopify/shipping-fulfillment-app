class ItemShippingRates
  def initialize(credentials, items, destination)
    @credentials = credentials
    @items = prepare(items)
    @destination = locate(destination)
  end

  def fetch_rates
    Rails.cache.fetch(rates_cache_key, expires_in: 1.day) do
      shipwire = ActiveMerchant::Shipping::Shipwire.new(@credentials)
      response = shipwire.find_rates(nil, @destination, nil, items: @items)
      response.estimates.collect { |estimate| rate_from_estimate(estimate) }
    end
  rescue ActiveMerchant::Shipping::ResponseError
    nil
  end

  private

  def prepare(items)
    items = items.select { |item| item[:requires_shipping] && item[:fulfillment_service] == "shipwire" }
    items.map(&:attributes)
  end

  def rates_cache_key
    "ItemShippingRates:#{@order.id}"
  end

  def locate(destination)
    params = destination.slice(*ActiveMerchant::Shipping::Location.column_names)
    ActiveMerchant::Shipping::Location.new(params)
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

end