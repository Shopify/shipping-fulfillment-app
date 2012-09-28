class ExternalController < ApplicationController
  #respond_to :json#, only: [:shipping_rates, :fetch_stock]#TODO change after testing

  skip_before_filter :verify_authenticity_token
  skip_before_filter :shop_exists
  skip_around_filter :shopify_session

  # before_filter :verify_shopify_request
  before_filter :symbolize_params

  # rescue_from Exception {|exception| head :ok } unless Rails.env == 'test'

  def shipping_rates
    @rates = ShippingRates(@shop.credentials, @params[:items],@params[:destination]).rate_from_estimate
    @rates.to_json
  end

  def fetch_stock
    @shop = Shop.find_by_domain @params[:shop]
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(@shop.credentials)
    response = shipwire.fetch_stock_levels(:sku => @params[:sku])
    stock_levels = response.stock_levels
    respond_to do |format|
      format.json { render :json => stock_levels }
      format.xml { render :xml => build_stock_xml(stock_levels) }
    end
  end

  def fetch_tracking_numbers
    shipwire = ActiveMerchant::Shipping::Shipwire.new(@shop.credentials)
    order_ids = convert_to_array(@params[:order_ids])
    response = shipwire.fetch_tracking_numbers(order_ids)
    tracking_numbers = response.tracking_numbers
    respond_to do |format|
      format.json { render :json => tracking_numbers }
      format.xml { render :xml => build_tracking_xml(tracking_numbers) }
    end
  end

  def fulfill_order
    head :ok
  end

  def convert_to_array(string_array)
    string_array[0...-1].split(',').map { |el| el.to_i }
  end

  private

  def build_stock_xml(stock_levels)
    output = "<StockLevels>"
    stock_levels.keys.each do |key|
      output.concat("<Product><Sku>" + key + "</Sku><Quantity>" + stock_levels[key].to_s + "</Quantity></Product>")
    end
    output.concat "</StockLevels>"
  end

  def build_tracking_xml(tracking_numbers)
    output = "<TrackingNumbers>"
    tracking_numbers.keys.each do |key|
      output.concat("<Order><ID>" + key + "</ID><Tracking>" + tracking_numbers[key] + "</Tracking></Order>")
    end
    output.concat "</TrackingNumbers>"
  end

  def verify_shopify_request
    data = request.body.read.to_s
    digest = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ShipwireApp::Application.config.shopify.secret, data)).strip
    head :unauthorized unless calculated_hmac == hmac
    request.body.rewind
  end

  def hmac
    request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
  end

  def symbolize_params
    @params = params.with_indifferent_access
  end

  def credentials
    domain = request.headers['HTTP_X_SHOPIFY_SHOP_DOMAIN']
    @shop = Shop.find_by_domain(domain)
  end

end

