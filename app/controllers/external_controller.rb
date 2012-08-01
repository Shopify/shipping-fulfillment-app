class ExternalController < ApplicationController
  respond_to :json, only: [:shipping_rates]

  skip_before_filter :verify_authenticity_token
  skip_before_filter :shop_exists
  skip_around_filter :shopify_session

  before_filter :verify_shopify_request, :symbolize_params

  rescue_from Exception {|exception| head :ok } unless Rails.env == 'test'

  def shipping_rates
    @rates = ItemShippingRates(credentials, @params[:items],@params[:destination]).rate_from_estimate
    @rates.to_json
  end

  private

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
    Shop.find_by_domain(domain).credentials
  end

end
