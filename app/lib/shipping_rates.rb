# Calculates rates for an order or hashes of line_items
class ShippingRates
  def initialize(credentials, params)
    @credentials = credentials
    @order = Order.find(params[:id]) if params.has_key?(:id)
    @items = prepare_items(params)
    @destination = prepare_destination(params)
  end

  def fetch_rates
    Rails.cache.fetch(rates_cache_key, expires_in: 1.day) do |shipwire|
      shipwire = ActiveMerchant::Shipping::Shipwire.new(@credentials)
      response = shipwire.find_rates(nil, @destination, nil, items: @items)
      response.estimates.collect { |estimate| extract_rate(estimate) }
    end
  rescue ActiveMerchant::Shipping::ResponseError, ActiveMerchant::ConnectionError
    nil
  end

  private

  def rates_cache_key
    return "ShippingRates:#{@order.id}" if @order
    "ShippingRates:#{item_ids}"
  end

  def item_ids
    @items.map(&:id).map(&:to_s).join('-')
  end

  def prepare_items(params)
    if @order
      items = @order.line_items.select { |item| item.requires_shipping && item.fulfillment_service == "shipwire" }
    else
      items = params[:items].select{ |item| item[:requires_shipping] && item[:fulfillment_service] == "shipwire" }
    end
    items.map(&:attributes)
  end

  def prepare_destination(params)
    if @order
      address = @order.shipping_address

      location = {
        country: address.country,
        province: address.province,
        city: address.city,
        address1: address.address1,
      }
    else
      location = params[:destination].slice(:country, :province, :city, :address1)
    end
    ActiveMerchant::Shipping::Location.new(location)
  end

  def extract_rate(estimate)
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