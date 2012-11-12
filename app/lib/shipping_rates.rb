# Calculates rates for an order or hashes of line_items
class ShippingRates
  def initialize(credentials, params)
    @credentials = credentials
    @items = prepare_items(params)
    @destination = prepare_destination(params)
  end

  def fetch_rates
    shipwire = carrier_service_class.new(@credentials)
    response = shipwire.find_rates(nil, @destination, nil, items: @items)
    response.estimates.collect { |estimate| extract_rate(estimate) }
  end

  private

  def item_ids
    @items.map(&:id).map(&:to_s).join('-')
  end

  def prepare_items(params)
    params[:items].select{ |item| item[:requires_shipping] && item[:fulfillment_service] == "shipwire-app" }
  end

  def prepare_destination(params)
    location = params[:destination].slice(:country, :province, :city, :address1).merge({:zip => params[:destination][:postal_code]})
    ActiveMerchant::Shipping::Location.new(location)
  end

  def extract_rate(estimate)
    price = (estimate.total_price.to_f / 100).round(2).to_s
    {
      service_name: estimate.service_name,
      service_code: estimate.service_code,
      total_price:  estimate.total_price,
      currency:     estimate.currency
      # estimated_delivery_date: estimate.delivery_date,
      # estimated_delivery_range: estimate.delivery_range
    }
  end

  def carrier_service_class
    ShipwireApp::Application.config.shipwire_carrier_service_class
  end
end