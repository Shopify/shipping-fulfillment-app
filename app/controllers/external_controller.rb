class ExternalController < ApplicationController
  respond_to :json, only: [:shipping_rates, :fetch_stock, :fetch_tracking_numbers]

  skip_before_filter :verify_authenticity_token
  skip_before_filter :shop_exists
  skip_around_filter :shopify_session

  before_filter :symbolize_params
  before_filter :verify_shopify_request


  def shipping_rates
    shop = Shop.find_by_domain(shop_domain)
    rates = ShippingRates.new(shop.credentials, @params[:rate]).fetch_rates
    render :json => rates
  end

  def fetch_stock
    stock_request = @params[:stock_levels]
    shop = Shop.find_by_domain(shop_domain)
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(shop.credentials)
    response = shipwire.fetch_stock_levels(:sku => stock_request[:sku])
    stock_levels = response.stock_levels
    render :json => stock_levels
  end

  def fetch_tracking_numbers
    shop = Shop.find_by_domain(shop_domain)
    shipwire = ActiveMerchant::Fulfillment::ShipwireService.new(shop.credentials)
    order_ids = (@params[:order_ids])
    response = shipwire.fetch_tracking_numbers(order_ids)
    tracking_numbers = response.tracking_numbers
    render :json => tracking_numbers
  end

  private

  def verify_shopify_request
    data = request.body.read.to_s
    digest = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ShipwireApp::Application.config.shopify.secret, data)).strip
    head :unauthorized unless calculated_hmac == hmac
    request.body.rewind
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

end

