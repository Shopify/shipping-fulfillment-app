class ExternalController < ApplicationController
  respond_to :json, only: [:shipping_rates, :fetch_stock, :fetch_tracking_numbers]

  skip_before_filter :verify_authenticity_token
  skip_before_filter :shop_exists
  skip_around_filter :shopify_session

  before_filter :symbolize_params


  def shipping_rates
    shop = Shop.find_by_domain(shop_domain)
    response = ShippingRates.new(shop.credentials, @params[:rate])
    rates = response.fetch_rates
    render :json => {:rates => rates}
  end

  def fetch_stock
    unless verify_shopify_request({ 'sku' => @params[:sku], 'shop' => @params[:shop]})
      head(:unauthorized)
    else
      shop = Shop.find_by_domain(shop_domain)
      shipwire = fulfillment_service_class.new(shop.credentials.merge({:include_empty_stock => true}))
      response = shipwire.fetch_stock_levels(:sku => @params[:sku])
      stock_levels = response.stock_levels
      render :json => stock_levels
    end
  end

  def fetch_tracking_numbers
    shop = Shop.find_by_domain(shop_domain)
    shipwire = fulfillment_service_class.new(shop.credentials)
    order_ids = (@params[:order_ids])
    response = shipwire.fetch_tracking_numbers(order_ids)
    tracking_numbers = response.tracking_numbers
    render :json => tracking_numbers
  end

  private

  def verify_shopify_request(data)
    digest = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ShipwireApp::Application.config.shopify.secret, data.to_param)).strip
    request.body.rewind
    calculated_hmac == hmac
  end

  def shop_domain
    request.headers['HTTP_X_SHOPIFY_SHOP_DOMAIN']
  end

  def hmac
    request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
  end

  def symbolize_params
    @params = params.with_indifferent_access
  end

  def fulfillment_service_class
    ShipwireApp::Application.config.shipwire_fulfillment_service_class
  end

end

