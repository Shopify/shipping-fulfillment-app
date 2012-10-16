# Calculates rates for an order or hashes of line_items
class ShippingRates
  def initialize(credentials, params)
    @credentials = credentials
    @order = Order.find(params[:id]) if params.has_key?(:id)
    @items = prepare_items(params)
    @destination = prepare_destination(params)
  end

  def fetch_rates
    shipwire = ActiveMerchant::Shipping::Shipwire.new(@credentials)
    response = shipwire.find_rates(nil, @destination, nil, items: @items)
    response.estimates.collect { |estimate| extract_rate(estimate) }
  end

  private

  def item_ids
    @items.map(&:id).map(&:to_s).join('-')
  end

  def prepare_items(params)
    if @order
      items = @order.line_items.select { |item| item.requires_shipping && item.fulfillment_service == "shipwire-app" }
    else
      items = params[:items].select{ |item| item[:requires_shipping] && item[:fulfillment_service] == "shipwire-app" }
    end
    items
  end

  def prepare_destination(params)
    if @order

      location = {
        country: @order.country,
        province: @order.province,
        city: @order.city,
        address1: @order.address1,
        zip: @order.postal_code
      }
    else
      location = params[:destination].slice(:country, :province, :city, :address1).merge({:zip => params[:destination][:postal_code]})
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